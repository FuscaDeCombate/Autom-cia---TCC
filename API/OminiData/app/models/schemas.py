from pydantic import BaseModel
from datetime import datetime
from typing import Optional, List


class ConnectionRequest(BaseModel):
    api_key: str
    app_id: str
    database_name: Optional[str] = None


class ConnectionResponse(BaseModel):
    # Dados separados para cada linguagem montar a sua própria connection ‘string’
    server: str
    database: str
    username: str
    password: str
    port: Optional[int] = 1433

    # Dados adicionais
    expires_in: int
    timestamp: datetime
    temp_user_id: str
    allowed_procedures: List[str]


class ApiKeyValidation(BaseModel):
    is_valid: bool
    app_name: str
    allowed_procedures: List[str]


class ProcedureListResponse(BaseModel):
    database_name: str
    available_procedures: List[str]