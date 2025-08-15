from time import process_time

from fastapi import Request
from starlette.middleware.base import BaseHTTPMiddleware, RequestResponseEndpoint
from starlette.responses import Response

from app.core.logger import log
import time

class LoggingMiddleWare(BaseHTTPMiddleware):
    async def dispatch(self, request: Request, call_next: RequestResponseEndpoint) -> Response:
        start_time = time.time()

        # Log da requisição
        log(f"{request.method} {request.url.path} - Cliente: {request.client.host}", "INFO")

        response = await call_next(request)

        # Log da resposta
        process_time = time.time() - start_time
        status_color = "SUCCESS" if response.status_code < 400 else "ERROR"
        log(f"{request.method} {request.url.path} - Status: {response.status_code} - Tempo: {process_time:.2f}", status_color)

        return response