from pydantic import BaseModel
from datetime import datetime
from typing import Optional


class ConnectionRequest(BaseModel):
    api_key: str
    app_id: str
    database_name: Optional[str] = None
    permissions: Optional[str] = "read"  # read, write, admin


class ConnectionResponse(BaseModel):
    connection_string: str
    expires_in: int
    timestamp: datetime
    temp_user_id: str


class ApiKeyValidation(BaseModel):
    is_valid: bool
    app_name: str
    permissions: list