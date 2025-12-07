from fastapi import APIRouter, Depends, HTTPException, UploadFile, File, Form
from sqlalchemy.orm import Session
from typing import Optional
from uuid import UUID, uuid4
import numpy as np
from PIL import Image
import io

from ..core.database import get_db
from ..models.equipment import Equipment
from ..models.scan import ScanMetadata
from ..schemas.scan import ScanAnalysisResponse, ChatRequest, ChatResponse, ScanMetadataCreate
from ..services.tflite_inference import TFLiteModel
from ..services.ai_chat import GeminiChat

router = APIRouter(prefix="/scan", tags=["Scanning"])

# Initialize ML model and AI chat (singleton)
tflite_model = TFLiteModel()
gemini_chat = GeminiChat()

@router.post("/analyze", response_model=ScanAnalysisResponse)
async def analyze_image(
    image: UploadFile = File(...),
    user_id: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Analyze equipment image using TFLite model"""
    # Validate file type
    if not image.content_type.startswith("image/"):
        raise HTTPException(status_code=400, detail="File must be an image")
    
    # Read image
    image_bytes = await image.read()
    
    # Validate file size (10MB limit)
    if len(image_bytes) > 10 * 1024 * 1024:
        raise HTTPException(status_code=400, detail="Image size exceeds 10MB limit")
    
    try:
        # Open image with PIL
        pil_image = Image.open(io.BytesIO(image_bytes))
        
        # Run inference
        predictions = tflite_model.predict(pil_image)
        
        # Get top prediction
        class_name = predictions['class_name']
        confidence = predictions['confidence']
        
        # Check confidence threshold
        if confidence < 0.5:
            raise HTTPException(
                status_code=400,
                detail=f"Low confidence ({confidence:.2%}). Please take a clearer photo."
            )
        
        # Query equipment database
        equipment = db.query(Equipment).filter(Equipment.class_name == class_name).first()
        
        if not equipment:
            raise HTTPException(
                status_code=404,
                detail=f"Equipment class '{class_name}' recognized but not in database"
            )
        
        # Create scan ID
        scan_id = uuid4()
        
        # If user is authenticated, log to database
        if user_id:
            try:
                scan_metadata = ScanMetadata(
                    scan_id=scan_id,
                    user_id=UUID(user_id),
                    equipment_id=equipment.equipment_id,
                    confidence_score=confidence
                )
                db.add(scan_metadata)
                db.commit()
            except Exception as e:
                print(f"Error saving scan metadata: {e}")
                # Continue even if metadata save fails
        
        # Return enriched response
        return ScanAnalysisResponse(
            scan_id=scan_id,
            equipment_id=equipment.equipment_id,
            equipment_name=equipment.name_en,
            class_name=equipment.class_name,
            confidence_score=confidence,
            category=equipment.category,
            description=equipment.description_en,
            usage=equipment.usage_en,
            safety_info=equipment.safety_info_en,
            image_url=equipment.image_url,
            tags=equipment.tags or []
        )
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Error analyzing image: {str(e)}"
        )

@router.post("/chat", response_model=ChatResponse)
async def chat_with_ai(
    request: ChatRequest,
    db: Session = Depends(get_db)
):
    """Chat with AI about identified equipment"""
    # Get equipment details
    equipment = db.query(Equipment).filter(Equipment.equipment_id == request.equipment_id).first()
    
    if not equipment:
        raise HTTPException(status_code=404, detail="Equipment not found")
    
    # Build context
    context = {
        "equipment_name": equipment.name_en,
        "category": equipment.category,
        "description": equipment.description_en,
        "usage": equipment.usage_en,
        "safety_info": equipment.safety_info_en
    }
    
    try:
        # Generate AI response
        ai_response = gemini_chat.generate_response(
            equipment_context=context,
            user_message=request.user_message,
            conversation_history=request.conversation_history
        )
        
        return ChatResponse(message=ai_response)
        
    except Exception as e:
        # Fallback to mock response if AI fails
        return ChatResponse(
            message=f"I understand you're asking about {request.equipment_name}. This is a {equipment.category.lower()} equipment. How can I help you learn more about it?"
        )

@router.post("/sync")
async def sync_scans(
    scans: list[ScanMetadataCreate],
    db: Session = Depends(get_db)
):
    """Sync scan metadata to cloud (for authenticated users)"""
    synced_count = 0
    
    for scan_data in scans:
        try:
            # Check if scan already exists
            existing = db.query(ScanMetadata).filter(
                ScanMetadata.user_id == scan_data.user_id,
                ScanMetadata.equipment_id == scan_data.equipment_id,
                ScanMetadata.scanned_at == scan_data.scanned_at
            ).first()
            
            if not existing:
                scan_metadata = ScanMetadata(**scan_data.dict())
                db.add(scan_metadata)
                synced_count += 1
        except Exception as e:
            print(f"Error syncing scan: {e}")
            continue
    
    db.commit()
    
    return {
        "message": f"Successfully synced {synced_count} scans",
        "synced_count": synced_count
    }

@router.get("/history")
async def get_scan_history(
    user_id: UUID,
    limit: int = 50,
    offset: int = 0,
    db: Session = Depends(get_db)
):
    """Get user's scan history metadata from cloud"""
    scans = db.query(ScanMetadata).filter(
        ScanMetadata.user_id == user_id
    ).order_by(
        ScanMetadata.scanned_at.desc()
    ).offset(offset).limit(limit).all()
    
    return {"scans": scans, "total": len(scans)}
