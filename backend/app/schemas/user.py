from pydantic import BaseModel, EmailStr
from typing import Optional
from datetime import datetime
from uuid import UUID

class UserBase(BaseModel):
    email: Optional[EmailStr] = None
    full_name: Optional[str] = None
    phone_number: Optional[str] = None

class UserCreate(UserBase):
    auth_method: str
    google_id: Optional[str] = None

class UserResponse(BaseModel):
    user_id: UUID
    auth_method: str
    email: Optional[str] = None
    full_name: Optional[str] = None
    phone_number: Optional[str] = None
    profile_picture: Optional[str] = None
    language_preference: str
    created_at: datetime
    last_login_at: Optional[datetime] = None
    
    class Config:
        from_attributes = True

class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user: UserResponse
