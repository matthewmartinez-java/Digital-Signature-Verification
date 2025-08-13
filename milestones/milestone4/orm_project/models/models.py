# models.py
#
# This file is where you define your ORM models. Models represent tables in the database,
# and each instance of a model corresponds to a row in that table.
#
# Models should inherit from the `Base` class, which provides methods for interacting with the database,
# such as saving records, querying, and deleting.
#
# In this file, you will:
#   - Define your own models, from your database schema in this project, by subclassing the `Base` class.
#   - Use `Column` objects to define columns and their types (e.g., `Integer`, `String`).
#   - Add attributes to each model class to represent columns in the corresponding database table.
#   - Define additional methods in the models as necessary for specific functionality (e.g., custom queries,
#     business logic, etc.).
#
#
# Students should implement their own models, specifying the columns using `Column` and selecting the appropriate
# `types` for each column, such as `Integer`, `String`, `Boolean`, etc.
#
# Below you can find two models examples that demonstrate the usage of the base class

from orm.columns import Column
from orm.datatypes import Integer, String, Boolean
from orm.base import Base


class User(Base):

    user_id = Column(Integer, primary_key=True)
    email = Column(String(100), nullable=False)
    password = Column(String(100), nullable=False)
    tracking_id = Column(Integer, unique=True)
    role_id = Column(Integer, foreign_key=True)
    organization_id = Column(Integer, foreign_key=True)

    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.user_id = kwargs.get('user_id')
        self.email = kwargs.get('email')
        self.password = kwargs.get('password')
        self.tracking_id = kwargs.get('tracking_id')
        self.role_id = kwargs.get('role_id')
        self.organization_id = kwargs.get('organization_id')
        self.foreign_keys = []

    def descriptor(self):
        return self.__class__.__name__.lower()


class Role(Base):
    role_id = Column(Integer, primary_key=True)
    title = Column(String(50))
    permissions = Column(String(100))

    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.role_id = kwargs.get('role_id')
        self.title = kwargs.get('title')
        self.permissions = kwargs.get('permissions')


class Organization(Base):
    organization_id = Column(Integer, primary_key=True)
    name = Column(String(100), nullable=False)
    sector = Column(String(100))
    region = Column(String(100))

    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.organization_id = kwargs.get('organization_id')
        self.name = kwargs.get('name')
        self.sector = kwargs.get('sector')
        self.region = kwargs.get('region')


class Document(Base):
    document_id = Column(Integer, primary_key=True)
    title = Column(String(255), nullable=False)
    content = String(type="TEXT")
    upload_time = Column(String("DATETIME"))
    organization_id = Column(Integer, foreign_key=True)

    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.document_id = kwargs.get('document_id')
        self.title = kwargs.get('title')
        self.content = kwargs.get('content')
        self.upload_time = kwargs.get('upload_time')
        self.organization_id = kwargs.get('organization_id')


class Signature(Base):
    signature_id = Column(Integer, primary_key=True)
    hash = Column(String(255), nullable=False)
    timestamp = Column(String("DATETIME"), nullable=False)
    digital_certificate_id = Column(Integer, foreign_key=True)
    user_id = Column(Integer, foreign_key=True)
    document_id = Column(Integer, foreign_key=True)

    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.signature_id = kwargs.get('signature_id')
        self.hash = kwargs.get('hash')
        self.timestamp = kwargs.get('timestamp')
        self.digital_certificate_id = kwargs.get('digital_certificate_id')
        self.user_id = kwargs.get('user_id')
        self.document_id = kwargs.get('document_id')


class DigitalCertificate(Base):
    digital_certificate_id = Column(Integer, primary_key=True)
    user_id = Column(Integer, foreign_key=True)
    issue_date = Column(String("DATE"))
    expiration_date = Column(String("DATE"))
    fingerprint = Column(String(255))

    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.digital_certificate_id = kwargs.get('digital_certificate_id')
        self.user_id = kwargs.get('user_id')
        self.issue_date = kwargs.get('issue_date')
        self.expiration_date = kwargs.get('expiration_date')
        self.fingerprint = kwargs.get('fingerprint')


class Session(Base):
    session_id = Column(Integer, primary_key=True)
    user_id = Column(Integer, foreign_key=True)
    start_time = Column(String("DATETIME"))
    end_time = Column(String("DATETIME"))
    ip_address = Column(String(255))
    failedAttempts = Column(Integer)
    lockedUntil = Column(String("DATETIME"))
    result = Column(String(50))

    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.session_id = kwargs.get('session_id')
        self.user_id = kwargs.get('user_id')
        self.start_time = kwargs.get('start_time')
        self.end_time = kwargs.get('end_time')
        self.ip_address = kwargs.get('ip_address')
        self.failedAttempts = kwargs.get('failedAttempts')
        self.lockedUntil = kwargs.get('lockedUntil')
        self.result = kwargs.get('result')


class AuditLog(Base):
    audit_log_id = Column(Integer, primary_key=True)
    user_id = Column(Integer, foreign_key=True)
    verification_event_id = Column(Integer, foreign_key=True)
    action = Column(String(255))
    timestamp = Column(String("DATETIME"))
    result = Column(String(50))
    method = Column(String(100))
    ip = Column(String(255))

    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.audit_log_id = kwargs.get('audit_log_id')
        self.user_id = kwargs.get('user_id')
        self.verification_event_id = kwargs.get('verification_event_id')
        self.action = kwargs.get('action')
        self.timestamp = kwargs.get('timestamp')
        self.result = kwargs.get('result')
        self.method = kwargs.get('method')
        self.ip = kwargs.get('ip')


class VerificationEvent(Base):
    verification_event_id = Column(Integer, primary_key=True)
    user_id = Column(Integer, foreign_key=True)
    document_id = Column(Integer, foreign_key=True)
    timestamp = Column(String("DATETIME"))
    result = Column(String(50))
    audit_log_id = Column(Integer, foreign_key=True)

    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.verification_event_id = kwargs.get('verification_event_id')
        self.user_id = kwargs.get('user_id')
        self.document_id = kwargs.get('document_id')
        self.timestamp = kwargs.get('timestamp')
        self.result = kwargs.get('result')
        self.audit_log_id = kwargs.get('audit_log_id')


class HashRecord(Base):
    hash_id = Column(Integer, primary_key=True)
    document_id = Column(Integer, foreign_key=True)
    hash_value = Column(String(255))
    algorithm = Column(String(50))
    created_at = Column(String("DATETIME"))

    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.hash_id = kwargs.get('hash_id')
        self.document_id = kwargs.get('document_id')
        self.hash_value = kwargs.get('hash_value')
        self.algorithm = kwargs.get('algorithm')
        self.created_at = kwargs.get('created_at')


class Notification(Base):
    notification_id = Column(Integer, primary_key=True)
    user_id = Column(Integer, foreign_key=True)
    document_id = Column(Integer, foreign_key=True)
    timestamp = Column(String("DATETIME"))
    type = Column(String(50))
    content = Column(String(255))
    read_unread = Column(Boolean)

    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.notification_id = kwargs.get('notification_id')
        self.user_id = kwargs.get('user_id')
        self.document_id = kwargs.get('document_id')
        self.timestamp = kwargs.get('timestamp')
        self.type = kwargs.get('type')
        self.content = kwargs.get('content')
        self.read_unread = kwargs.get('read_unread')


class AccessControlEntry(Base):
    user_id = Column(Integer, primary_key=True)
    document_id = Column(Integer, primary_key=True)
    access_type = Column(String(50))  # read/write/revoke
    granted_at = Column(String("DATETIME"))
    expires_at = Column(String("DATETIME"))

    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.user_id = kwargs.get('user_id')
        self.document_id = kwargs.get('document_id')
        self.access_type = kwargs.get('access_type')
        self.granted_at = kwargs.get('granted_at')
        self.expires_at = kwargs.get('expires_at')


class PublicKey(Base):
    public_key_id = Column(Integer, primary_key=True)
    digital_certificate_id = Column(Integer, foreign_key=True)
    key_material = Column(String(255))
    format = Column(String(50))
    last_used = Column(String("DATETIME"))

    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.public_key_id = kwargs.get('public_key_id')
        self.digital_certificate_id = kwargs.get('digital_certificate_id')
        self.key_material = kwargs.get('key_material')
        self.format = kwargs.get('format')
        self.last_used = kwargs.get('last_used')


class PrivateKey(Base):
    private_key_id = Column(Integer, primary_key=True)
    digital_certificate_id = Column(Integer, foreign_key=True)
    key_material = Column(String(255))
    rotation_date = Column(String("DATETIME"))
    mfa_bound = Column(Boolean)

    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.private_key_id = kwargs.get('private_key_id')
        self.digital_certificate_id = kwargs.get('digital_certificate_id')
        self.key_material = kwargs.get('key_material')
        self.rotation_date = kwargs.get('rotation_date')
        self.mfa_bound = kwargs.get('mfa_bound')


class SignatureRevocation(Base):
    revocation_id = Column(Integer, primary_key=True)
    reason = Column(String(255))
    revoked_at = Column(String("DATETIME"))
    signature_id = Column(Integer, foreign_key=True)

    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.revocation_id = kwargs.get('revocation_id')
        self.reason = kwargs.get('reason')
        self.revoked_at = kwargs.get('revoked_at')
        self.signature_id = kwargs.get('signature_id')





