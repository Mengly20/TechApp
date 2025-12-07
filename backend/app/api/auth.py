from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import Optional
import random
from datetime import datetime, timedelta
from google.oauth2 import id_token
from google.auth.transport import requests
from uuid import UUID

from ..core.database import get_db
from ..core.redis import get_redis
from ..core.security import create_access_token
from ..core.config import settings
from ..models.user import User, AuthMethod
from ..schemas.user import TokenResponse, UserResponse
from pydantic import BaseModel

router = APIRouter(prefix="/auth", tags=["Authentication"])

class GoogleSignInRequest(BaseModel):
    id_token: str
    device_info: Optional[dict] = None

class SendOTPRequest(BaseModel):
    phone_number: str
    country_code: str = "KH"

class VerifyOTPRequest(BaseModel):
    phone_number: str
    otp_code: str

class SignOutRequest(BaseModel):
    token: str

@router.post("/google-signin", response_model=TokenResponse)
async def google_signin(
    request: GoogleSignInRequest,
    db: Session = Depends(get_db)
):
    """Authenticate user with Google OAuth ID token"""
    try:
        # Verify Google ID token (in production, uncomment this)
        # idinfo = id_token.verify_oauth2_token(
        #     request.id_token,
        #     requests.Request(),
        #     settings.GOOGLE_CLIENT_ID
        # )
        # google_id = idinfo['sub']
        # email = idinfo['email']
        # name = idinfo.get('name')
        # picture = idinfo.get('picture')
        
        # For demo purposes, use mock data
        google_id = f"google_{random.randint(10000, 99999)}"
        email = f"user{random.randint(1000, 9999)}@gmail.com"
        name = "Demo User"
        picture = None
        
        # Check if user exists
        user = db.query(User).filter(User.google_id == google_id).first()
        
        if not user:
            # Create new user
            user = User(
                auth_method=AuthMethod.GOOGLE,
                google_id=google_id,
                email=email,
                full_name=name,
                profile_picture=picture,
                last_login_at=datetime.utcnow()
            )
            db.add(user)
        else:
            # Update last login
            user.last_login_at = datetime.utcnow()
        
        db.commit()
        db.refresh(user)
        
        # Create JWT token
        access_token = create_access_token(
            data={"sub": str(user.user_id), "auth_method": user.auth_method.value}
        )
        
        return TokenResponse(
            access_token=access_token,
            user=UserResponse.from_orm(user)
        )
        
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=f"Invalid Google token: {str(e)}"
        )

@router.post("/send-otp")
async def send_otp(
    request: SendOTPRequest,
    redis = Depends(get_redis)
):
    """Send OTP code to phone number"""
    # Validate phone number format
    if not request.phone_number.startswith("+"):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Phone number must be in E.164 format (e.g., +855123456789)"
        )
    
    # Check rate limit
    rate_key = f"otp_rate:{request.phone_number}"
    attempts = redis.get(rate_key)
    if attempts and int(attempts) >= 3:
        raise HTTPException(
            status_code=status.HTTP_429_TOO_MANY_REQUESTS,
            detail="Too many OTP requests. Please try again in 1 hour."
        )
    
    # Generate 6-digit OTP
    otp_code = str(random.randint(100000, 999999))
    
    # Store OTP in Redis (5 minutes expiry)
    otp_key = f"otp:{request.phone_number}"
    redis.setex(otp_key, 300, otp_code)
    
    # Increment rate limit counter (1 hour expiry)
    redis.incr(rate_key)
    redis.expire(rate_key, 3600)
    
    # Send SMS (in production, use Twilio)
    # from twilio.rest import Client
    # client = Client(settings.TWILIO_ACCOUNT_SID, settings.TWILIO_AUTH_TOKEN)
    # message = client.messages.create(
    #     body=f"Your EdTech Scanner OTP is: {otp_code}",
    #     from_=settings.TWILIO_PHONE_NUMBER,
    #     to=request.phone_number
    # )
    
    # For demo, just log the OTP
    print(f"OTP for {request.phone_number}: {otp_code}")
    
    return {
        "message": "OTP sent successfully",
        "phone_number": request.phone_number,
        "expires_in": 300  # seconds
    }

@router.post("/verify-otp", response_model=TokenResponse)
async def verify_otp(
    request: VerifyOTPRequest,
    db: Session = Depends(get_db),
    redis = Depends(get_redis)
):
    """Verify OTP code and authenticate user"""
    otp_key = f"otp:{request.phone_number}"
    stored_otp = redis.get(otp_key)
    
    if not stored_otp:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="OTP not found or expired"
        )
    
    # Check failed attempts
    attempts_key = f"otp_attempts:{request.phone_number}"
    attempts = redis.get(attempts_key)
    if attempts and int(attempts) >= 3:
        redis.delete(otp_key)
        raise HTTPException(
            status_code=status.HTTP_429_TOO_MANY_REQUESTS,
            detail="Too many failed attempts. Please request a new OTP."
        )
    
    # Verify OTP
    if stored_otp != request.otp_code:
        redis.incr(attempts_key)
        redis.expire(attempts_key, 300)
        remaining = 3 - int(redis.get(attempts_key))
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=f"Invalid OTP. {remaining} attempts remaining."
        )
    
    # OTP is valid, delete it
    redis.delete(otp_key)
    redis.delete(attempts_key)
    
    # Check if user exists
    user = db.query(User).filter(User.phone_number == request.phone_number).first()
    
    if not user:
        # Create new user
        user = User(
            auth_method=AuthMethod.PHONE,
            phone_number=request.phone_number,
            last_login_at=datetime.utcnow()
        )
        db.add(user)
    else:
        user.last_login_at = datetime.utcnow()
    
    db.commit()
    db.refresh(user)
    
    # Create JWT token
    access_token = create_access_token(
        data={"sub": str(user.user_id), "auth_method": user.auth_method.value}
    )
    
    return TokenResponse(
        access_token=access_token,
        user=UserResponse.from_orm(user)
    )

@router.post("/signout")
async def signout(
    request: SignOutRequest,
    redis = Depends(get_redis)
):
    """Sign out user and blacklist token"""
    # Add token to blacklist (24 hours expiry)
    blacklist_key = f"blacklist:{request.token}"
    redis.setex(blacklist_key, 86400, "1")
    
    return {"message": "Successfully signed out"}

@router.post("/refresh-token")
async def refresh_token():
    """Refresh JWT token (Phase 2 feature)"""
    raise HTTPException(
        status_code=status.HTTP_501_NOT_IMPLEMENTED,
        detail="Token refresh not yet implemented"
    )
