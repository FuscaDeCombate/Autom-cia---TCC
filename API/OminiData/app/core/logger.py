RESET = "\033[0m"

COLORS = {
    "INFO": "\033[34m",      # Azul
    "SUCCESS": "\033[32m",   # Verde
    "WARNING": "\033[33m",   # Amarelo
    "ERROR": "\033[31m",     # Vermelho
    "DEBUG": "\033[35m",     # Magenta
}

def log(message: str, level: str = "INFO"):
    colors = COLORS.get(level.upper(), "\033[37m")  # Padrão: Branco
    message = f"{colors}{message}{RESET}"
    print(f"{colors}{level.upper():<9}{RESET} {message}")
