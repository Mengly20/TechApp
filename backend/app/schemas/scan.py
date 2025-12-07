from pydantic import BaseModel
from typing import Optional, List, Dict, Any
from uuid import UUID
from datetime import datetime

class ScanAnalysisRequest(BaseModel):
    user_id: Optional[UUID] = None

class ScanAnalysisResponse(BaseModel):
    scan_id: UUID
    equipment_id: UUID
    equipment_name: str
    class_name: str
    confidence_score: float
    category: str
    description: str
    usage: str
    safety_info: Optional[str] = None
    image_url: Optional[str] = None
    tags: List[str] = []

class ChatRequest(BaseModel):
    equipment_id: UUID
    equipment_name: str
    user_message: str
    conversation_history: List[Dict[str, str]] = []

class ChatResponse(BaseModel):
    message: str
    timestamp: datetime = datetime.utcnow()

class ScanMetadataCreate(BaseModel):
    user_id: UUID
    equipment_id: UUID
    confidence_score: float
    device_info: Optional[Dict[str, Any]] = None

class ScanMetadataResponse(BaseModel):
    scan_id: UUID
    user_id: UUID
    equipment_id: UUID
    confidence_score: float
    scanned_at: datetime
    
    class Config:
        from_attributes = True
