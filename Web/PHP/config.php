<?php
// config.php - Configurações do banco de dados e constantes do sistema

// Configurações do banco de dados SQL Server
define('DB_SERVER', 'XUXAOOG\SQLEXPRESS');
define('DB_NAME', 'Automacia');
define('DB_USERNAME', ''); // Altere para seu usuário
define('DB_PASSWORD', '');   // Altere para sua senha

// Configurações de email
define('SMTP_HOST', 'smtp.gmail.com'); // Servidor SMTP
define('SMTP_PORT', 587);
define('SMTP_USERNAME', 'Automacia@gmail.com'); // Seu email
define('SMTP_PASSWORD', '1234123');       // Senha de app do Gmail
define('SMTP_FROM_EMAIL', 'seu_email@gmail.com');
define('SMTP_FROM_NAME', 'Sistema Automacia');

// Tempo de expiração do código (em minutos)
define('CODE_EXPIRATION_TIME', 10);

// Conexão com o banco de dados
function getConnection() {
    try {
        $connectionInfo = array(
            "Database" => DB_NAME,
            "UID" => DB_USERNAME,
            "PWD" => DB_PASSWORD,
            "CharacterSet" => "UTF-8"
        );
        
        $conn = sqlsrv_connect(DB_SERVER, $connectionInfo);
        
        if ($conn === false) {
            throw new Exception("Erro na conexão: " . print_r(sqlsrv_errors(), true));
        }
        
        return $conn;
    } catch (Exception $e) {
        error_log($e->getMessage());
        return false;
    }
}

// Função para fechar conexão
function closeConnection($conn) {
    if ($conn) {
        sqlsrv_close($conn);
    }
}

// Função para retornar JSON
function returnJson($success, $message, $data = null) {
    header('Content-Type: application/json; charset=utf-8');
    echo json_encode([
        'success' => $success,
        'message' => $message,
        'data' => $data
    ], JSON_UNESCAPED_UNICODE);
    exit;
}
?>
