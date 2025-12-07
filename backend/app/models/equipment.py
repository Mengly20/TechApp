from sqlalchemy import Column, String, Text, DateTime
from sqlalchemy.dialects.postgresql import UUID, ARRAY
from datetime import datetime
import uuid
import json
from ..core.database import Base

# JSON type for SQLite compatibility
class JSONEncodedList(Text):
    """Stores list as JSON for SQLite compatibility"""
    cache_ok = True
    
    def bind_processor(self, dialect):
        def process(value):
            if value is None:
                return None
            return json.dumps(value)
        return process
    
    def result_processor(self, dialect, coltype):
        def process(value):
            if value is None:
                return []
            try:
                return json.loads(value)
            except:
                return []
        return process

class Equipment(Base):
    __tablename__ = "equipment"
    
    equipment_id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    class_name = Column(String(100), unique=True, nullable=False, index=True)
    name_en = Column(String(255), nullable=False)
    name_km = Column(String(255), nullable=True)
    category = Column(String(100), nullable=False, index=True)
    description_en = Column(Text, nullable=False)
    description_km = Column(Text, nullable=True)
    usage_en = Column(Text, nullable=False)
    usage_km = Column(Text, nullable=True)
    safety_info_en = Column(Text, nullable=True)
    safety_info_km = Column(Text, nullable=True)
    image_url = Column(String(512), nullable=True)
    tags = Column(JSONEncodedList, nullable=True, default=list)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
