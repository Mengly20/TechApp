import os
from .config import settings

# In-memory redis mock for development
class MemoryRedis:
    def __init__(self):
        self.data = {}
    
    def get(self, key):
        import time
        item = self.data.get(key)
        if item and item.get('expires') and item['expires'] < time.time():
            del self.data[key]
            return None
        return item.get('value') if item else None
    
    def setex(self, key, seconds, value):
        import time
        self.data[key] = {
            'value': value,
            'expires': time.time() + seconds
        }
    
    def delete(self, *keys):
        for key in keys:
            self.data.pop(key, None)
    
    def incr(self, key):
        current = self.get(key)
        new_val = (int(current) if current else 0) + 1
        self.data[key] = {'value': str(new_val), 'expires': None}
        return new_val
    
    def expire(self, key, seconds):
        import time
        if key in self.data:
            self.data[key]['expires'] = time.time() + seconds

# Use in-memory redis for dev or real redis for production
if settings.REDIS_URL.startswith("redis://") or settings.REDIS_URL.startswith("rediss://"):
    import redis
    redis_client = redis.from_url(settings.REDIS_URL, decode_responses=True)
else:
    redis_client = MemoryRedis()

def get_redis():
    """Get Redis client"""
    return redis_client
