from sqlalchemy import Column, String, Boolean, DateTime, Enum as SQLEnum
from datetime import datetime
import uuid
import enum
from ..core.database import Base

class AuthMethod(str, enum.Enum):
    GOOGLE = "google"
    PHONE = "phone"
    GUEST = "guest"

class User(Base):
    __tablename__ = "users"
    
    user_id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    auth_method = Column(SQLEnum(AuthMethod), nullable=False)
    google_id = Column(String(255), unique=True, nullable=True)
    phone_number = Column(String(20), unique=True, nullable=True)
    email = Column(String(255), unique=True, nullable=True)
    full_name = Column(String(255), nullable=True)
    profile_picture = Column(String(512), nullable=True)
    language_preference = Column(String(5), default="en")
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    last_login_at = Column(DateTime, nullable=True)
    deleted_at = Column(DateTime, nullable=True)
