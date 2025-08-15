from datetime import datetime, timedelta
from app.services.sql_server_service import SqlServerService
from app.models.schemas import ConnectionResponse
from app.core.config import settings
from app.core.logger import log


class ConnectionService:
    def __init__(self):
        self.sql_service = SqlServerService()
        log("ConnectionService inicializado", "INFO")

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
            app_name = self.valid_api_keys[api_key]["app_name"]
            log(f"API Key para a aplicação: {app_name}", "SUCCESS")
            return {
                "is_valid": True,
                **self.valid_api_keys[api_key]
            }
        log(f"Tentativa de acesso com API Key inválida: {api_key[:8]}***", "WARNING")
        return {"is_valid": False, "app_name": "", "allowed_procedures": []}

    async def create_connection(self, app_id: str, database_name: str, allowed_procedures: list) -> ConnectionResponse:
        """Cria conexão temporária com acesso APENAS às stored procedures especificadas"""
        log(f"Criando conexão temporária para app_id: {app_id}, database: {database_name}", "INFO")
        try:
            # Criar usuário temporário com acesso apenas às procedures
            temp_credentials = self.sql_service.create_temporary_user(
                app_id=app_id,
                database_name=database_name,
                allowed_procedures=allowed_procedures
            )

            log(f"Conexão temporária criada com sucesso para {app_id}", "SUCCESS")

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
        except Exception as e:
            log(f"Erro ao criar conexão para {app_id}: {str(e)}", "ERROR")
            raise

    async def list_available_procedures(self, database_name: str) -> list:
        """Lista todas as stored procedures disponíveis no database"""
        log(f"Listando procedures disponíveis para database: {database_name}", "INFO")
        try:
            procedures = self.sql_service.get_available_procedures(database_name)
            log(f"Encontradas {len(procedures)} procedures em {database_name}", "SUCCESS")
            return procedures
        except Exception as e:
            log(f"Erro ao listar procedures em {database_name}: {str(e)}", "ERROR")
            raise