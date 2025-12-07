from pydantic import BaseModel
from typing import Optional, List
from uuid import UUID
from datetime import datetime

class EquipmentBase(BaseModel):
    class_name: str
    name_en: str
    name_km: Optional[str] = None
    category: str
    description_en: str
    description_km: Optional[str] = None
    usage_en: str
    usage_km: Optional[str] = None
    safety_info_en: Optional[str] = None
    safety_info_km: Optional[str] = None
    image_url: Optional[str] = None
    tags: List[str] = []

class EquipmentCreate(EquipmentBase):
    pass

class EquipmentResponse(EquipmentBase):
    equipment_id: UUID
    created_at: datetime
    updated_at: datetime
    
    class Config:
        from_attributes = True

class EquipmentListResponse(BaseModel):
    total: int
    items: List[EquipmentResponse]
