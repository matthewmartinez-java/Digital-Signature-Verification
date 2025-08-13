USE dsvs;

/*
    Business Requirement #1
    --------------------------
    Purpose:     Automatically revoke access to documents once expired in AccessControlEntry

    Description: Each AccessControlEntry record has a granted_at and expires_at timestamp.
                 The system must ensure that no user can still have access to a document
                 after the expiration time.

    Challenge:   Users could still access documents via stale application logic if access
                 is not actively revoked in the backend. To do this, I need to enforce
                 dynamic time-sensitive permissions.

    Assumptions: The expiration time is set at the time of grant and cannot be NULL.
                 Must track revocations by moving expired entries into a table for audit.

    Implementation Plan:
        1. Create a table to store revoked access entries.
        2. Create a scheduled event to run daily and revoke all expired access entries.
        3. Move expired entries to the audit table and delete them from AccessControlEntry.

*/

-- 1
CREATE TABLE IF NOT EXISTS AccessRevocationLog (
    user_id INT,
    document_id INT,
    access_type VARCHAR(50),
    revoked_at DATETIME DEFAULT NOW()
);

-- 2
DELIMITER $$

CREATE EVENT IF NOT EXISTS RevokeExpiredAccess
ON SCHEDULE EVERY 1 DAY
DO
BEGIN
    -- Move expired entries to archive log
    INSERT INTO AccessRevocationLog (user_id, document_id, access_type, revoked_at)
    SELECT user_id, document_id, access_type, NOW()
    FROM AccessControlEntry
    WHERE expires_at IS NOT NULL AND expires_at < NOW();

    -- Delete expired access entries
    DELETE FROM AccessControlEntry
    WHERE expires_at IS NOT NULL AND expires_at < NOW();
END$$

DELIMITER ;

/*
    Business Requirement #2
    --------------------------
    Purpose:     Validate that a digital certificate is currently trusted before allowing it
                 to be used for signing or verification.

    Description: Digital Certificates must be checked before use to ensure they have not
                 expired or been revoked. This logic should be centralized and reusable
                 throughout the system.

    Challenge:   Certificate trust depends on the following two time-sensitive conditions:
                    1. The certificate has not expired
                    2. The certificate has not been revoked

    Assumptions: Each certificate may be associated with multiple signatures

    Implementation Plan:
        1. Create a function that:
            - Accepts a certificate ID
            - Returns TRUE if the certification is still valid and not revoked
        2. Use this function for any procedure that requires a certificate validation

*/

-- 1
DELIMITER $$

CREATE FUNCTION IsCertificateTrusted(p_certificate_id INT)
RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    DECLARE v_valid INT;
    DECLARE v_revoked INT;

    -- Check if certificate is expired
    SELECT COUNT(*) INTO v_valid
    FROM DigitalCertificate
    WHERE digital_certificate_id = p_certificate_id
    AND CURRENT_DATE BETWEEN issue_date AND expiration_date;

    -- Check that no signature linked to this certificate has been revoked
    SELECT COUNT(*) INTO v_revoked
    FROM SignatureRevocation SR
    JOIN Signature S ON SR.signature_id = S.signature_id
    WHERE S.digital_certificate_id = p_certificate_id;

    -- If valid and not revoked, return TRUE
    RETURN v_valid > 0 AND v_revoked = 0;
END$$

DELIMITER ;

/*
    Business Requirement #3
    --------------------------
    Purpose:     Automatically log all verification events to the AuditLog table for
                 traceability and auditing.

    Description: Every time a record is inserted into the VerificationEvent table,
                 the system should automatically log the corresponding user ID,
                 document ID, result, and timestamp into AuditLog.

    Challenge:   Manual logging is error-prone and inconsistent. To maintain a clean
                 and reliable audit trail, this process must be automatic.

    Assumptions: Each VerificationEvent is uniquely linked to a user and document

    Implementation Plan:
        1. Create an AFTER INSERT trigger on the VerificationEvent table
        2. On every insert, extract the relevant info and insert it into the AuditLog table

*/

DELIMITER $$

CREATE TRIGGER AfterVerificationEventInsert
AFTER INSERT ON VerificationEvent
FOR EACH ROW
BEGIN
    INSERT INTO AuditLog (
        audit_log_id,
        user_id,
        verification_event_id,
        action,
        timestamp,
        result,
        method,
        ip
    )
    VALUES (
        NULL,
        NEW.user_id,
        NEW.verification_event_id,
        'Verification Performed',
        NEW.timestamp,
        NEW.result,
        'system-triggered',
        'system-ip'
    );
END$$

DELIMITER ;

/*
    Business Requirement #4
    --------------------------
    Purpose:     Restrict signature or certificate revocation to admin users only.

    Description: Not all users should be able to revoke sensitive information like
                 signatures or digital certificates. This logic will enforce Role
                 Based Access Control before revocation is allowed.

    Challenge:   Application-level enforcement can be bypassed. Access must be
                 enforced at the database layer using stored procedures and functions.

    Assumptions: Revocation is performed through a stored process

    Implementation Plan:
        1. Create a function that checks if a given user_id is an admin
        2. Create a stored procedure that:
            - Accepts a user_id and signature_id
            - Verifies admin status
            - If authorized, inserts a revocation entry into SignatureRevocation

*/

-- 1
DELIMITER $$

CREATE FUNCTION IsUserAdmin(p_user_id INT)
RETURNS BOOLEAN
DETERMINISTIC
BEGIN
        DECLARE v_role_title VARCHAR(50);

        SELECT R.title INTO v_role_title
        FROM User U
        JOIN Role R ON U.role_id = R.role_id
        WHERE U.user_id = p_user_id;

        RETURN v_role_title = 'admin';
END$$

-- 2
CREATE PROCEDURE RevokeSignatureIfAuthorized(
    IN p_user_id INT,
    IN p_signature_id INT,
    IN p_reason TEXT
)
BEGIN
        DECLARE is_admin BOOLEAN;

        -- Check admin access
        SET is_admin = IsUserAdmin(p_user_id);

        IF is_admin THEN
            INSERT INTO SignatureRevocation (reason, revoked_at, signature_id)
            VALUES (p_reason, NOW(), p_signature_id);
        ELSE
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Unauthorized: Only admin users can revoke signatures.';
        END IF;
END$$

DELIMITER ;

/*
    Business Requirement #5
    --------------------------
    Purpose:     Detect and flag suspicious device usage during session creation.

    Description: If a session is created from a device marked as untrusted or flagged,
                 the system must raise an alert. The session could also be prevented
                 entirely.

    Challenge:   Enforcing this at the database level means integrating two separate
                 entities: Sessions and Devices. The system must detect risks based on
                 the trust status stored in the Device table.

    Assumptions: Devices are linked to users through Device.user_id.
                 Trust_status can be 'trusted', 'untrusted', or 'flagged'.

    Implementation Plan:
        1. Create a trigger on the sessions table
        2. When a session is created, check the user's device trust_status
        3. If 'flagged' or 'untrusted', log it in AuditLog for review

*/

DELIMITER $$

CREATE TRIGGER BeforeSessionInsert_CheckDevice
BEFORE INSERT ON Session
FOR EACH ROW
BEGIN
    DECLARE v_trust_status VARCHAR(50);

    -- Get device's trust status
    SELECT trust_status INTO v_trust_status
    FROM Device
    WHERE user_id = NEW.user_id
    ORDER BY last_used DESC
    LIMIT 1;

    -- If flagged or untrusted, log it
    IF v_trust_status IN ('flagged', 'untrusted') THEN
        INSERT INTO AuditLog (
            audit_log_id,
            user_id,
            verification_event_id,
            action,
            timestamp,
            result,
            method,
            ip
        )
        VALUES (
            NULL,
            NEW.user_id,
            NULL,
            CONCAT('Suspicious device login attempt - Status: ', v_trust_status),
            NOW(),
            'flagged',
            'triggered-device-check',
            NEW.ip_address
        );
    END IF;
END$$

DELIMITER ;

/*
    Business Requirement #6
    --------------------------
    Purpose:     Ensure a document has been signed by all required roles before it is
                 marked as complete.

    Description: Some documents may require multiple signatures from specific roles like
                 employee, supervisor, and manager. This procedure checks whether all required
                 signatures exist for a document.

    Challenge:   A document may have multiple signatures, but ensuring all required roles have
                 signed it requires a JOIN between Role and Signature and validation logic.

    Assumptions: Required roles for a document are 'Admin' and 'Verifier'
                 Document ID is passed as input

    Implementation Plan:
        1. Create a procedure 'CheckDocumentSignature'
        2. It will accept a document_id
        3. It will return TRUE if both the 'admin' and 'verifier' roles have signed
        4. Otherwise, return an error

*/

DELIMITER $$

CREATE PROCEDURE CheckDocumentSignature(
    IN p_document_id INT
)
BEGIN
    DECLARE admin_signed INT DEFAULT 0;
    DECLARE verifier_signed INT DEFAULT 0;

    -- check if an admin signed this document
    SELECT COUNT(*) INTO admin_signed
    FROM Signature S
    JOIN User U ON S.user_id = U.user_id
    JOIN Role R ON U.role_id = R.role_id
    WHERE S.document_id = p_document_id AND R.title = 'admin';

    -- check if a verifier signed this document
    SELECT COUNT(*) INTO verifier_signed
    FROM Signature S
    JOIN User U ON S.user_id = U.user_id
    JOIN Role R ON U.role_id = R.role_id
    WHERE S.document_id = p_document_id AND R.title = 'verifier';

    -- Error if missing
    IF admin_signed = 0 OR verifier_signed = 0 THEN
       SIGNAL SQLSTATE '45000'
       SET MESSAGE_TEXT = 'Document missing required signatures.';
    END IF;
END$$

DELIMITER ;


/*
    Business Requirement #7
    --------------------------
    Purpose:     Proactively monitor and log digital certificates that are expiring within
                 7 days.

    Description: Certificates close to expiration are a security risk. This system should check
                 daily for these certifications and insert a log entry into AuditLog for each
                 expiring certification, alerting the admin.

    Challenge:   Automating secure expiration tracking while avoiding unnecessary duplicates.
                 This event must run efficiently and not duplicate alerts.

    Assumptions: Will be implemented using a scheduled EVENT
                 Duplicate alerts for the same certification should be avoided

    Implementation Plan:
        1. Create a scheduled EVENT that runs daily
        2. It finds certifications expiring within 7 days
        3. It inserts an alert into AuditLog for each certification, with same user_id

*/

DELIMITER $$

CREATE EVENT IF NOT EXISTS LogExpiringCertificates
ON SCHEDULE EVERY 1 DAY
DO
BEGIN
    INSERT INTO AuditLog (
        audit_log_id,
        user_id,
        verification_event_id,
        action,
        timestamp,
        result,
        method,
        ip
    )
    SELECT
        NULL,
        user_id,
        NULL,
        CONCAT('Certificate expiring soon (ID ', digital_certificate_id, ')'),
        NOW(),
        'warning',
        'expiration-check',
        'system-ip'
    FROM DigitalCertificate
    WHERE DATEDIFF(expiration_date, CURDATE()) BETWEEN 0 AND 7;
END$$

DELIMITER ;

/*
    Business Requirement #8
    --------------------------
    Purpose:     Ensure that the stored public key has not been tampered with by validating its
                 hash against what's stored in the HashRecord table.

    Description: Public keys are very important for verifying signatures. If an attacker modifies
                 a key in the database, that would test the integrity of the database structure. To
                 protect against this, the system must store hash of the key in 'HashRecord' and
                 validate the key's current state against it.

    Challenge:   Must handle cryptographic hash comparison securely and very quickly. Hash validation
                 must be used to detect unauthorized modifications to keys and more sensitive data.

    Assumptions: N/A

    Implementation Plan:
        1. Create a DETERMINISTIC FUNCTION
        2. Accepts a 'public_key_id'
        3. Hashes the key and compares it to the stored hash in 'HashRecord'

*/

DELIMITER $$

CREATE FUNCTION IsPublicKeyValid(p_public_key_id INT, p_document_id INT)
RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    DECLARE v_stored_hash VARCHAR(255);
    DECLARE v_computed_hash VARCHAR(255);
    DECLARE v_key_material TEXT;

    -- Get the stored key material
    SELECT key_material INTO v_key_material
    FROM PublicKey
    WHERE public_key_id = p_public_key_id;

    -- Hash using SHA2-256
    SET v_computed_hash = SHA2(v_key_material, 256);

    -- Get the stored hash
    SELECT hash_value INTO v_stored_hash
    FROM HashRecord
    WHERE document_id = p_document_id
    ORDER BY created_at DESC
    LIMIT 1;

    -- Compare computed and stored hash
    RETURN v_computed_hash = v_stored_hash;
END$$

DELIMITER ;

/*
    Business Requirement #9
    --------------------------
    Purpose:     Enforce account lockouts after 3 failed verification attempts, and restore access
                 after 24 hrs.

    Description: If a user fails verification 3 or more times, their account should be locked to
                 prevent brute force attempts. This will be done by storing 'failedAttempts' and
                 'lockedUntil' fields into the Session table and enforcing a lockout for 24 hours.
                 A scheduled event will reset access once the lockout expires.

    Challenge:   Since SQL triggers can't drop privileges, this design enforces locks through
                 database fields and prevent access via application logic or any future procedures.

    Assumptions: Insertions into Session simulate login attempts
                 A view will list currently locked accounts

    Implementation Plan:
        1. ALTER Session table to include 'failedAttempts; and 'lockedUntil'
        2. Create BEFORE INSERT trigger that:
            - Increments 'failedAttempts' on failure
            - Sets 'lockedUntil' if failures reach 3
        3. Create EVENT to reset failedAttempts if 'lockedUntil' < NOW()
        4. Create a VIEW that lists locked accounts

*/

-- 1
ALTER TABLE Session
ADD COLUMN failedAttempts INT DEFAULT 0,
ADD COLUMN lockedUntil DATETIME DEFAULT NULL;

-- 2
DELIMITER $$

CREATE TRIGGER BeforeSessionInsertLockout
BEFORE INSERT ON Session
FOR EACH ROW
BEGIN
    DECLARE v_failed INT DEFAULT 0;
    DECLARE v_locked DATETIME DEFAULT NULL;

    -- Checks for previous sessions
    IF EXISTS (
        SELECT 1 FROM Session WHERE user_id = NEW.user_id
    ) THEN
    -- Checks lock state
        SELECT IFNULL(failedAttempts, 0), lockedUntil
        INTO v_failed, v_locked
        FROM Session
        WHERE user_id = NEW.user_id
        ORDER BY start_time DESC
        LIMIT 1;
    END IF;

    -- If locked, block insert
IF v_locked IS NOT NULL AND v_locked > NOW() THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Account is currently locked.';
END IF;

    -- If login failed, attempts ++
    IF NEW.result = 'failure' THEN
       SET NEW.failedAttempts = v_failed + 1;

        IF NEW.failedAttempts >= 3 THEN
           SET NEW.lockedUntil = NOW() + INTERVAL 24 HOUR;
        END IF;
    ELSE
        SET NEW.failedAttempts = 0;
        SET NEW.lockedUntil = NULL;
    END IF;
END$$

DELIMITER ;

-- 3
DELIMITER $$

CREATE EVENT IF NOT EXISTS ResetLockedAccounts
ON SCHEDULE EVERY 1 HOUR
DO
BEGIN
    UPDATE Session
    SET failedAttempts = 0,
        lockedUntil = NULL
    WHERE lockedUntil IS NOT NULL AND lockedUntil < NOW();
END$$

DELIMITER ;

-- 4
CREATE OR REPLACE VIEW LockedAccounts AS
SELECT user_id, MAX(lockedUntil) AS lock_expiration
FROM Session
WHERE lockedUntil IS NOT NULL AND lockedUntil > NOW()
GROUP BY user_id;

/*
    Business Requirement #10
    --------------------------
    Purpose:     Generate a monthly summary report of user actions for auditing and monitoring
                 purposes.

    Description: Over time, the AuditLog table accumulates many entries. To support monthly reporting,
                 this requirement creates a summary table that aggregates user activity, grouped by
                 result type.

    Challenge:   Performing grouped aggregations over a growing log efficiently, and structuring the
                 data to support future reporting (charts).

    Assumptions: A new table will be created to hold summary records
                 This will run as a procedure or a scheduled monthly event

    Implementation Plan:
        1. Create a new table 'AuditLogMonthlySummary'
        2. Create a procedure to populate it
        3. Each row includes: user_id, month, result type, count
        4. Summary can be run manually or a scheduled event

*/

-- 1
CREATE TABLE IF NOT EXISTS AuditLogMonthlySummary (
    summary_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    result VARCHAR(50),
    action_count INT,
    summary_month DATE
);

-- 2
DELIMITER $$

CREATE PROCEDURE GenerateAuditSummary()
BEGIN
    INSERT INTO AuditLogMonthlySummary (user_id, result, action_count, summary_month)
    SELECT
        user_id,
        result,
        COUNT(*) AS action_count,
        DATE_FORMAT(NOW(), '%Y-%m-01') AS summary_month
    FROM AuditLog
    WHERE timestamp >= DATE_FORMAT(NOW() - INTERVAL 1 MONTH, '%Y-%m-01')
        AND timestamp < DATE_FORMAT(NOW(), '%Y-%m-01')
    GROUP BY user_id, result;
END$$

DELIMITER ;
















