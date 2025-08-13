USE dsvs;
-- Sample data insert script for Digital Signature Verification System

INSERT INTO Role (role_id, title, permissions) VALUES
(1, 'admin', 'full'),
(2, 'user', 'basic'),
(3, 'verifier', 'verify_only');

INSERT INTO Organization (organization_id, name) VALUES
(1, 'CyberOrg'),
(2, 'DataTrust'),
(3, 'SecuServe');

INSERT INTO User (user_id, email, password, tracking_id, role_id, organization_id) VALUES
(1, 'alice@example.com', 'pass123', 1001, 1, 1),
(2, 'bob@example.com', 'pass456', 1002, 2, 2),
(3, 'carol@example.com', 'pass789', 1003, 3, 3);

INSERT INTO Account (account_id, user_id, created_at, status, validated) VALUES
(1, 1, NOW(), 'active', 1),
(2, 2, NOW(), 'suspended', 0),
(3, 3, NOW(), 'active', 1);

INSERT INTO Document (document_id, title, content, upload_time, organization_id) VALUES
(1, 'Policy.pdf', 'EncryptedContent1', NOW(), 1),
(2, 'Report.docx', 'EncryptedContent2', NOW(), 2),
(3, 'Plan.txt', 'EncryptedContent3', NOW(), 3);

INSERT INTO DigitalCertificate (digital_certificate_id, user_id, issue_date, expiration_date, fingerprint) VALUES
(1, 1, NOW(), DATE_ADD(NOW(), INTERVAL 1 YEAR), 'ABC123'),
(2, 2, NOW(), DATE_ADD(NOW(), INTERVAL 1 YEAR), 'DEF456'),
(3, 3, NOW(), DATE_ADD(NOW(), INTERVAL 1 YEAR), 'GHI789');

INSERT INTO PublicKey (public_key_id, digital_certificate_id, key_material, format, last_used) VALUES
(1, 1, 'pubkey1', 'PEM', NOW()),
(2, 2, 'pubkey2', 'PEM', NOW()),
(3, 3, 'pubkey3', 'PEM', NOW());

INSERT INTO PrivateKey (private_key_id, digital_certificate_id, key_material, rotation_date, mfa_bound) VALUES
(1, 1, 'privkey1', NOW(), 1),
(2, 2, 'privkey2', NOW(), 0),
(3, 3, 'privkey3', NOW(), 1);

INSERT INTO Signature (signature_id, hash, timestamp, digital_certificate_id) VALUES
(1, 'hash1', NOW(), 1),
(2, 'hash2', NOW(), 2),
(3, 'hash3', NOW(), 3);

INSERT INTO SignatureRevocation (revocation_id, reason, revoked_at, signature_id) VALUES
(1, 'Key compromise', NOW(), 1),
(2, 'User left organization', NOW(), 2),
(3, 'Expiration', NOW(), 3);

INSERT INTO CertificateAuthority (certificate_authority_id, name, authority_public_key, organization_id, status) VALUES
(1, 'GlobalTrust', 'CAKey1', 1, 'active'),
(2, 'SecureSign', 'CAKey2', 2, 'active'),
(3, 'CertifyNow', 'CAKey3', 3, 'revoked');

INSERT INTO Session (session_id, user_id, start_time, end_time, ip_address) VALUES
(1, 1, NOW(), NOW(), '192.168.1.10'),
(2, 2, NOW(), NOW(), '192.168.1.20'),
(3, 3, NOW(), NOW(), '192.168.1.30');

INSERT INTO Device (device_id, user_id, trust_status, fingerprint, last_used) VALUES
(1, 1, 'trusted', 'devfp1', NOW()),
(2, 2, 'flagged', 'devfp2', NOW()),
(3, 3, 'trusted', 'devfp3', NOW());

INSERT INTO Notification (notification_id, user_id, document_id, timestamp, type, content, read_unread) VALUES
(1, 1, 1, NOW(), 'alert', 'Verification failed', 0),
(2, 2, 2, NOW(), 'success', 'Document verified', 1),
(3, 3, 3, NOW(), 'error', 'Invalid signature', 0);

INSERT INTO VerificationEvent (verification_event_id, user_id, document_id, timestamp, result, audit_log_id) VALUES
(1, 1, 1, NOW(), 'success', 1),
(2, 2, 2, NOW(), 'failure', 2),
(3, 3, 3, NOW(), 'success', 3);

INSERT INTO AuditLog (audit_log_id, user_id, verification_event_id, action, timestamp, result, method, ip) VALUES
(1, 1, 1, 'verify_signature', NOW(), 'success', 'auto', '192.168.1.10'),
(2, 2, 2, 'verify_signature', NOW(), 'failure', 'manual', '192.168.1.20'),
(3, 3, 3, 'revoke_certificate', NOW(), 'success', 'admin', '192.168.1.30');

INSERT INTO HashRecord (hash_id, document_id, hash_value, algorithm, created_at) VALUES
(1, 1, 'hashVal1', 'SHA-256', NOW()),
(2, 2, 'hashVal2', 'SHA-3', NOW()),
(3, 3, 'hashVal3', 'SHA-256', NOW());

INSERT INTO IPAddressLog (ip_address_log, session_id, verification_event_id, ip, location, flagged) VALUES
(1, 1, 1, '192.168.1.10', 'NYC', 0),
(2, 2, 2, '192.168.1.20', 'LA', 1),
(3, 3, 3, '192.168.1.30', 'SF', 0);

INSERT INTO AccessControlEntry (user_id, document_id, access_type, granted_at, expires_at) VALUES
(1, 1, 'read', NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY)),
(2, 2, 'write', NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY)),
(3, 3, 'revoke', NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY));
