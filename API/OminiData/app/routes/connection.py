from fastapi import APIRouter, HTTPException, Depends
from app.models.schemas import ConnectionRequest, ConnectionResponse, ProcedureListResponse
from app.services.connection_service import ConnectionService
from datetime import datetime

router = APIRouter()
connection_service = ConnectionService()


@router.post("/request", response_model=ConnectionResponse)
async def request_connection(request: ConnectionRequest):
    """Endpoint principal - solicita conexão temporária com acesso apenas a stored procedures"""

    # Validar API Key
    api_validation = await connection_service.validate_api_key(request.api_key)

    if not api_validation["is_valid"]:
        raise HTTPException(status_code=401, detail="API Key inválida")

    try:
        # Criar conexão temporária com acesso APENAS às procedures permitidas
        connection_data = await connection_service.create_connection(
            app_id=request.app_id,
            database_name=request.database_name or "DefaultDB",
            allowed_procedures=api_validation["allowed_procedures"]
        )

        return connection_data

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Erro interno: {str(e)}")


@router.get("/procedures/{database_name}", response_model=ProcedureListResponse)
async def list_procedures(database_name: str):
    """Lista todas as stored procedures disponíveis no database (apenas para admins)"""
    try:
        procedures = await connection_service.list_available_procedures(database_name)
        return ProcedureListResponse(
            database_name=database_name,
            available_procedures=procedures
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Erro ao listar procedures: {str(e)}")


@router.get("/my-procedures")
async def get_my_procedures(api_key: str):
    """Retorna as procedures que uma API key específica pode executar"""
    api_validation = await connection_service.validate_api_key(api_key)

    if not api_validation["is_valid"]:
        raise HTTPException(status_code=401, detail="API Key inválida")

    return {
        "app_name": api_validation["app_name"],
        "allowed_procedures": api_validation["allowed_procedures"]
    }


@router.get("/health")
async def health_check():
    """Endpoint de health check"""
    return {"status": "OminiData API is running!", "timestamp": datetime.now()}