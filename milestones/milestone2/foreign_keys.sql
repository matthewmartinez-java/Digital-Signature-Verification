USE dsvs;

ALTER TABLE User
  ADD CONSTRAINT fk_User_Organization FOREIGN KEY (organization_id) REFERENCES Organization(organization_id),
  ADD CONSTRAINT fk_User_Role FOREIGN KEY (role_id) REFERENCES Role(role_id);

ALTER TABLE Account
  ADD CONSTRAINT fk_Account_User FOREIGN KEY (user_id) REFERENCES User(user_id);

ALTER TABLE Document
  ADD CONSTRAINT fk_Document_Organization FOREIGN KEY (organization_id) REFERENCES Organization(organization_id);

ALTER TABLE AccessControlEntry
  ADD CONSTRAINT fk_ACE_User FOREIGN KEY (user_id) REFERENCES User(user_id),
  ADD CONSTRAINT fk_ACE_Document FOREIGN KEY (document_id) REFERENCES Document(document_id);

ALTER TABLE DigitalCertificate
  ADD CONSTRAINT fk_DC_User FOREIGN KEY (user_id) REFERENCES User(user_id);

ALTER TABLE CertificateAuthority
  ADD CONSTRAINT fk_CA_Organization FOREIGN KEY (organization_id) REFERENCES Organization(organization_id);

ALTER TABLE PublicKey
  ADD CONSTRAINT fk_PK_DigitalCertificate FOREIGN KEY (digital_certificate_id) REFERENCES DigitalCertificate(digital_certificate_id);

ALTER TABLE PrivateKey
  ADD CONSTRAINT fk_PrK_DigitalCertificate FOREIGN KEY (digital_certificate_id) REFERENCES DigitalCertificate(digital_certificate_id);

ALTER TABLE Signature
  ADD CONSTRAINT fk_Signature_DC FOREIGN KEY (digital_certificate_id) REFERENCES DigitalCertificate(digital_certificate_id);

ALTER TABLE SignatureRevocation
  ADD CONSTRAINT fk_SignatureRevocation_Signature FOREIGN KEY (signature_id) REFERENCES Signature(signature_id);

ALTER TABLE Session
  ADD CONSTRAINT fk_Session_User FOREIGN KEY (user_id) REFERENCES User(user_id);

ALTER TABLE Device
  ADD CONSTRAINT fk_Device_User FOREIGN KEY (user_id) REFERENCES User(user_id);

ALTER TABLE Notification
  ADD CONSTRAINT fk_Notification_User FOREIGN KEY (user_id) REFERENCES User(user_id),
  ADD CONSTRAINT fk_Notification_Document FOREIGN KEY (document_id) REFERENCES Document(document_id);

ALTER TABLE VerificationEvent
  ADD CONSTRAINT fk_VerificationEvent_User FOREIGN KEY (user_id) REFERENCES User(user_id),
  ADD CONSTRAINT fk_VerificationEvent_Document FOREIGN KEY (document_id) REFERENCES Document(document_id),
  ADD CONSTRAINT fk_VerificationEvent_AuditLog FOREIGN KEY (audit_log_id) REFERENCES AuditLog(audit_log_id);

ALTER TABLE AuditLog
  ADD CONSTRAINT fk_AuditLog_User FOREIGN KEY (user_id) REFERENCES User(user_id),
  ADD CONSTRAINT fk_AuditLog_VerificationEvent FOREIGN KEY (verification_event_id) REFERENCES VerificationEvent(verification_event_id);

ALTER TABLE HashRecord
  ADD CONSTRAINT fk_HashRecord_Document FOREIGN KEY (document_id) REFERENCES Document(document_id);

ALTER TABLE IPAddressLog
  ADD CONSTRAINT fk_IPAddressLog_Session FOREIGN KEY (session_id) REFERENCES Session(session_id),
  ADD CONSTRAINT fk_IPAddressLog_VerificationEvent FOREIGN KEY (verification_event_id) REFERENCES VerificationEvent(verification_event_id);
