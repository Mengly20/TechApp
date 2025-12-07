from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from typing import Optional, List
from uuid import UUID

from ..core.database import get_db
from ..models.equipment import Equipment
from ..schemas.equipment import EquipmentResponse, EquipmentListResponse, EquipmentCreate

router = APIRouter(prefix="/equipment", tags=["Equipment"])

@router.get("/list", response_model=EquipmentListResponse)
async def get_equipment_list(
    category: Optional[str] = None,
    search: Optional[str] = None,
    language: str = "en",
    limit: int = Query(50, le=100),
    offset: int = 0,
    db: Session = Depends(get_db)
):
    """Get list of all equipment with optional filters"""
    query = db.query(Equipment)
    
    # Apply filters
    if category:
        query = query.filter(Equipment.category == category)
    
    if search:
        if language == "km":
            query = query.filter(Equipment.name_km.ilike(f"%{search}%"))
        else:
            query = query.filter(Equipment.name_en.ilike(f"%{search}%"))
    
    # Get total count
    total = query.count()
    
    # Apply pagination
    equipment_list = query.offset(offset).limit(limit).all()
    
    return EquipmentListResponse(
        total=total,
        items=[EquipmentResponse.from_orm(eq) for eq in equipment_list]
    )

@router.get("/{equipment_id}", response_model=EquipmentResponse)
async def get_equipment_detail(
    equipment_id: UUID,
    db: Session = Depends(get_db)
):
    """Get detailed information about specific equipment"""
    equipment = db.query(Equipment).filter(Equipment.equipment_id == equipment_id).first()
    
    if not equipment:
        raise HTTPException(status_code=404, detail="Equipment not found")
    
    return EquipmentResponse.from_orm(equipment)

@router.get("/categories")
async def get_categories(db: Session = Depends(get_db)):
    """Get list of all equipment categories"""
    categories = db.query(Equipment.category).distinct().all()
    return {"categories": [cat[0] for cat in categories]}

@router.post("/", response_model=EquipmentResponse)
async def create_equipment(
    equipment: EquipmentCreate,
    db: Session = Depends(get_db)
):
    """Create new equipment (Admin only - for demo purposes)"""
    # Check if class_name already exists
    existing = db.query(Equipment).filter(Equipment.class_name == equipment.class_name).first()
    if existing:
        raise HTTPException(status_code=400, detail="Equipment class name already exists")
    
    new_equipment = Equipment(**equipment.dict())
    db.add(new_equipment)
    db.commit()
    db.refresh(new_equipment)
    
    return EquipmentResponse.from_orm(new_equipment)
