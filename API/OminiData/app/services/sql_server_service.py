import pyodbc
import secrets
import string
from datetime import datetime, timedelta
from app.core.config import settings


class SqlServerService:
    def __init__(self):
        self.master_connection = self._get_master_connection()

    def _get_master_connection(self):
        """Conexão master para gerenciar usuários temporários"""
        connection_string = (
            f"DRIVER={{ODBC Driver 17 for SQL Server}};"
            f"SERVER={settings.MASTER_SQL_SERVER};"
            f"DATABASE={settings.MASTER_SQL_DATABASE};"
            f"UID={settings.MASTER_SQL_USER};"
            f"PWD={settings.MASTER_SQL_PASSWORD};"
            f"TrustServerCertificate=yes;"
        )
        return pyodbc.connect(connection_string)

    def create_temporary_user(self, app_id: str, database_name: str, permissions: str = "read"):
        """Cria usuário temporário no SQL Server"""

        # Gerar credenciais temporárias
        temp_user = f"{settings.TEMP_USER_PREFIX}{app_id}_{secrets.token_hex(8)}"
        temp_password = self._generate_secure_password()

        try:
            cursor = self.master_connection.cursor()

            # Criar login
            create_login_sql = f"""
            IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = '{temp_user}')
            BEGIN
                CREATE LOGIN [{temp_user}] WITH PASSWORD = '{temp_password}'
            END
            """
            cursor.execute(create_login_sql)

            # Criar usuário no database específico
            cursor.execute(f"USE [{database_name}]")
            create_user_sql = f"""
            IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = '{temp_user}')
            BEGIN
                CREATE USER [{temp_user}] FOR LOGIN [{temp_user}]
            END
            """
            cursor.execute(create_user_sql)

            # Aplicar permissões baseadas no parâmetro
            if permissions == "read":
                cursor.execute(f"ALTER ROLE db_datareader ADD MEMBER [{temp_user}]")
            elif permissions == "write":
                cursor.execute(f"ALTER ROLE db_datawriter ADD MEMBER [{temp_user}]")
                cursor.execute(f"ALTER ROLE db_datareader ADD MEMBER [{temp_user}]")
            elif permissions == "admin":
                cursor.execute(f"ALTER ROLE db_owner ADD MEMBER [{temp_user}]")

            self.master_connection.commit()

            # Agendar remoção do usuário (você pode implementar com Celery ou similar)
            self._schedule_user_cleanup(temp_user, settings.DEFAULT_CONNECTION_TTL)

            return {
                "user": temp_user,
                "password": temp_password,
                "database": database_name
            }

        except Exception as e:
            self.master_connection.rollback()
            raise Exception(f"Erro ao criar usuário temporário: {str(e)}")

    def _generate_secure_password(self, length: int = 16):
        """Gera senha segura para usuário temporário"""
        characters = string.ascii_letters + string.digits + "!@#$%&*"
        return ''.join(secrets.choice(characters) for _ in range(length))

    def _schedule_user_cleanup(self, username: str, ttl_seconds: int):
        """Agenda limpeza do usuário temporário"""
        # Implementar com Celery, APScheduler ou similar
        # Por agora, apenas log
        cleanup_time = datetime.now() + timedelta(seconds=ttl_seconds)
        print(f"Usuário {username} agendado para remoção em {cleanup_time}")

    def cleanup_expired_users(self):
        """Remove usuários temporários expirados"""
        try:
            cursor = self.master_connection.cursor()

            # Buscar usuários temporários
            cursor.execute(f"""
                SELECT name FROM sys.server_principals 
                WHERE name LIKE '{settings.TEMP_USER_PREFIX}%'
            """)

            temp_users = cursor.fetchall()

            for user in temp_users:
                username = user[0]
                # Lógica para verificar se expirou (implementar baseado em timestamp)
                # Por agora, remove usuários mais antigos que 2 horas

                try:
                    # Remover usuário do database
                    cursor.execute(f"DROP USER IF EXISTS [{username}]")
                    # Remover login
                    cursor.execute(f"DROP LOGIN IF EXISTS [{username}]")
                    print(f"Usuário temporário {username} removido com sucesso")
                except Exception as e:
                    print(f"Erro ao remover usuário {username}: {str(e)}")

            self.master_connection.commit()

        except Exception as e:
            print(f"Erro na limpeza de usuários: {str(e)}")
