from datetime import datetime, timedelta
from app.services.sql_server_service import SqlServerService
from app.models.schemas import ConnectionResponse
from app.core.config import settings


class ConnectionService:
    def __init__(self):
        self.sql_service = SqlServerService()
        # Em produção, use Redis ou banco para armazenar API keys
        self.valid_api_keys = {
            "app-php-web-key-123": {"app_name": "PHP Web App", "permissions": ["read", "write"]},
            "app-android-mobile-key-456": {"app_name": "Android App", "permissions": ["read"]},
            "app-csharp-desktop-key-789": {"app_name": "C# Desktop App", "permissions": ["admin"]}
        }

    async def validate_api_key(self, api_key: str) -> dict:
        """Valida API key e retorna informações da aplicação"""
        if api_key in self.valid_api_keys:
            return {
                "is_valid": True,
                **self.valid_api_keys[api_key]
            }
        return {"is_valid": False, "app_name": "", "permissions": []}

    async def create_connection(self, app_id: str, database_name: str, permissions: str) -> ConnectionResponse:
        """Cria conexão temporária e retorna dados"""

        # Criar usuário temporário
        temp_credentials = self.sql_service.create_temporary_user(
            app_id=app_id,
            database_name=database_name,
            permissions=permissions
        )

        # Montar connection string
        connection_string = (
            f"DRIVER={{ODBC Driver 17 for SQL Server}};"
            f"SERVER={settings.MASTER_SQL_SERVER};"
            f"DATABASE={database_name};"
            f"UID={temp_credentials['user']};"
            f"PWD={temp_credentials['password']};"
            f"TrustServerCertificate=yes;"
        )

        return ConnectionResponse(
            connection_string=connection_string,
            expires_in=settings.DEFAULT_CONNECTION_TTL,
            timestamp=datetime.now(),
            temp_user_id=temp_credentials['user']
        )
