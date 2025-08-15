from fastapi import FastAPI
from app.middleware.logging_middleware import LoggingMiddleWare
from app.routes.connection import router as connection_router

app = FastAPI(
    title="OminiData API",
    description="API para gerenciamento seguro de conexões SQL Server",
    version="1.0.0"
)

# Incluir rotas
app.include_router(connection_router, prefix="/api/connection", tags=["connection"])

# Incluir MiddleWare
app.add_middleware(LoggingMiddleWare)

@app.get("/")
async def root():
    return {"message": "OminiData API - Sua conexão segura com SQL Server!"}
