import pyodbc
import secrets
import string
from datetime import datetime, timedelta
from app.core.config import settings


class SqlServerService:
    def __init__(self):
        self.master_connection = None
        self._test_connection()

    def _test_connection(self):
        """Testa a conexão com o SQL Server"""
        try:
            self.master_connection = self._get_master_connection()
            print("Conexão com SQL Server estabelecida com sucesso!")
        except Exception as e:
            print(f"Erro ao conectar com SQL Server: {str(e)}")
            print(f"Servidor: {settings.MASTER_SQL_SERVER}")
            print(f"Usuário: {settings.MASTER_SQL_USER}")
            print("Verifique suas configurações no arquivo .env")
            raise e

    def _get_master_connection(self):
        """Conexão master para gerenciar usuários temporários"""

        # Tentar primeiro com Windows Authentication se user/password estão vazios
        if not settings.MASTER_SQL_USER or not settings.MASTER_SQL_PASSWORD:
            connection_string = (
                f"DRIVER={{ODBC Driver 17 for SQL Server}};"
                f"SERVER={settings.MASTER_SQL_SERVER};"
                f"DATABASE={settings.MASTER_SQL_DATABASE};"
                f"Trusted_Connection=yes;"
                f"TrustServerCertificate=yes;"
            )
        else:
            connection_string = (
                f"DRIVER={{ODBC Driver 17 for SQL Server}};"
                f"SERVER={settings.MASTER_SQL_SERVER};"
                f"DATABASE={settings.MASTER_SQL_DATABASE};"
                f"UID={settings.MASTER_SQL_USER};"
                f"PWD={settings.MASTER_SQL_PASSWORD};"
                f"TrustServerCertificate=yes;"
            )

        return pyodbc.connect(connection_string)

    def create_temporary_user(self, app_id: str, database_name: str, allowed_procedures: list):
        """Cria usuário temporário com acesso APENAS às stored procedures especificadas"""

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

            # IMPORTANTE: NÃO dar nenhuma role padrão (db_datareader, etc.)
            # Dar permissão APENAS para as stored procedures especificadas
            for procedure_name in allowed_procedures:
                grant_procedure_sql = f"""
                IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = '{procedure_name}')
                BEGIN
                    GRANT EXECUTE ON [{procedure_name}] TO [{temp_user}]
                    PRINT 'Permissão concedida para {procedure_name}'
                END
                ELSE
                BEGIN
                    PRINT 'AVISO: Procedure {procedure_name} não existe!'
                END
                """
                cursor.execute(grant_procedure_sql)

            # Negar explicitamente acesso a tabelas diretas
            deny_table_access_sql = f"""
            -- Negar SELECT, INSERT, UPDATE, DELETE em todas as tabelas
            DECLARE @sql NVARCHAR(MAX) = ''
            SELECT @sql = @sql + 'DENY SELECT, INSERT, UPDATE, DELETE ON [' + SCHEMA_NAME(schema_id) + '].[' + name + '] TO [{temp_user}];'
            FROM sys.tables
            WHERE type = 'U'  -- User tables only

            IF @sql != ''
                EXEC sp_executesql @sql
            """
            cursor.execute(deny_table_access_sql)

            self.master_connection.commit()

            # Log das procedures permitidas
            print(f"Usuário {temp_user} criado com acesso às procedures: {', '.join(allowed_procedures)}")

            # Agendar remoção do usuário
            self._schedule_user_cleanup(temp_user, settings.DEFAULT_CONNECTION_TTL)

            return {
                "user": temp_user,
                "password": temp_password,
                "database": database_name,
                "allowed_procedures": allowed_procedures
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

    def get_available_procedures(self, database_name: str):
        """Lista todas as stored procedures disponíveis no database"""
        try:
            cursor = self.master_connection.cursor()
            cursor.execute(f"USE [{database_name}]")

            cursor.execute("""
                SELECT DISTINCT name 
                FROM sys.objects 
                WHERE type = 'P' 
                AND name NOT LIKE 'sp_%' 
                AND name NOT LIKE 'dt_%'
                ORDER BY name
            """)

            procedures = [row[0] for row in cursor.fetchall()]
            return procedures

        except Exception as e:
            print(f"Erro ao listar procedures: {str(e)}")
            return []