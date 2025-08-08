from datetime import datetime

from fastapi import APIRouter, HTTPException, Depends
from app.models.schemas import ConnectionRequest, ConnectionResponse
from app.services.connection_service import ConnectionService

router = APIRouter()
connection_service = ConnectionService()


@router.post("/request", response_model=ConnectionResponse)
async def request_connection(request: ConnectionRequest):
    """Endpoint principal - solicita conexão temporária"""

    # Validar API Key
    api_validation = await connection_service.validate_api_key(request.api_key)

    if not api_validation["is_valid"]:
        raise HTTPException(status_code=401, detail="API Key inválida")

    # Verificar se a aplicação tem permissão solicitada
    if request.permissions not in api_validation["permissions"]:
        raise HTTPException(
            status_code=403,
            detail=f"Aplicação não tem permissão '{request.permissions}'"
        )

    try:
        # Criar conexão temporária
        connection_data = await connection_service.create_connection(
            app_id=request.app_id,
            database_name=request.database_name or "DefaultDB",
            permissions=request.permissions
        )

        return connection_data

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Erro interno: {str(e)}")


@router.get("/health")
async def health_check():
    """Endpoint de health check"""
    return {"status": "OminiData API is running!", "timestamp": datetime.now()}
