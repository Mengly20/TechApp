from sqlalchemy import Column, String, Float, DateTime, ForeignKey, Text
from datetime import datetime
import uuid
import json
from ..core.database import Base

# JSON type for SQLite
class JSONType(Text):
    cache_ok = True
    def bind_processor(self, dialect):
        def process(value):
            return json.dumps(value) if value else None
        return process
    def result_processor(self, dialect, coltype):
        def process(value):
            return json.loads(value) if value else None
        return process

class ScanMetadata(Base):
    __tablename__ = "scan_metadata"
    
    scan_id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id = Column(String(36), ForeignKey("users.user_id"), nullable=False, index=True)
    equipment_id = Column(String(36), ForeignKey("equipment.equipment_id"), nullable=False, index=True)
    confidence_score = Column(Float, nullable=False)
    device_info = Column(JSONType, nullable=True)
    scanned_at = Column(DateTime, default=datetime.utcnow, index=True)
    synced_at = Column(DateTime, default=datetime.utcnow)
