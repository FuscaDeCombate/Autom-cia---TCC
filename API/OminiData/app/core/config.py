import os
from dotenv import load_dotenv

load_dotenv()

class Settings:
    # SQL Server principal (onde a API se conecta)
    MASTER_SQL_SERVER = os.getenv("MASTER_SQL_SERVER", "localhost")
    MASTER_SQL_DATABASE = os.getenv("MASTER_SQL_DATABASE", "master")
    MASTER_SQL_USER = os.getenv("MASTER_SQL_USER")
    MASTER_SQL_PASSWORD = os.getenv("MASTER_SQL_PASSWORD")

    # Configurações da API
    SECRET_KEY = os.getenv("SECRET_KEY", "sua-chave-super-secreta-aqui")
    TOKEN_EXPIRE_MINUTES = int(os.getenv("TOKEN_EXPIRE_MINUTES", "60"))

    # Configurações de conexões temporárias
    TEMP_USER_PREFIX = "omini_temp_"
    DEFAULT_CONNECTION_TTL = 3600  # 1 hora em segundos


settings = Settings()