from datetime import datetime, timedelta
from app.services.sql_server_service import SqlServerService
from app.models.schemas import ConnectionResponse
from app.core.config import settings


class ConnectionService:
    def __init__(self):
        self.sql_service = SqlServerService()
        # Em produção, use Redis ou banco para armazenar API keys
        # Agora cada app tem uma lista de procedures que pode executar
        self.valid_api_keys = {
            "app-php-web-key-123": {
                "app_name": "PHP Web App",
                "allowed_procedures": [
                    "sp_GetUsuarios",
                    "sp_InsertUsuario",
                ]
            },
            "app-android-mobile-key-456": {
                "app_name": "Android App",
                "allowed_procedures": [
                    "sp_GetProdutos",
                    "sp_GetCategorias",
                    "sp_LoginUsuario",
                    "sp_GetPerfilUsuario"
                ]
            },
            "app-csharp-desktop-key-789": {
                "app_name": "C# Desktop App",
                "allowed_procedures": [
                    "sp_BackupDatabase",
                    "sp_GetUsuarios",
                ]
            }
        }

    async def validate_api_key(self, api_key: str) -> dict:
        """Valida API key e retorna informações da aplicação"""
        if api_key in self.valid_api_keys:
            return {
                "is_valid": True,
                **self.valid_api_keys[api_key]
            }
        return {"is_valid": False, "app_name": "", "allowed_procedures": []}

    async def create_connection(self, app_id: str, database_name: str, allowed_procedures: list) -> ConnectionResponse:
        """Cria conexão temporária com acesso APENAS às stored procedures especificadas"""

        # Criar usuário temporário com acesso apenas às procedures
        temp_credentials = self.sql_service.create_temporary_user(
            app_id=app_id,
            database_name=database_name,
            allowed_procedures=allowed_procedures
        )

        # Retornar dados separados para cada linguagem usar
        return ConnectionResponse(
            server=settings.MASTER_SQL_SERVER,
            database=database_name,
            username=temp_credentials['user'],
            password=temp_credentials['password'],
            port=1433,  # Porta padrão SQL Server
            expires_in=settings.DEFAULT_CONNECTION_TTL,
            timestamp=datetime.now(),
            temp_user_id=temp_credentials['user'],
            allowed_procedures=allowed_procedures
        )

    async def list_available_procedures(self, database_name: str) -> list:
        """Lista todas as stored procedures disponíveis no database"""
        return self.sql_service.get_available_procedures(database_name)