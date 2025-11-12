<?php
// recsenha.php - Envio do código de recuperação
session_start();
header('Content-Type: application/json');

// Configurações do banco de dados
$serverName = "localhost";
$connectionInfo = array(
    "Database" => "Automacia",
    "UID" => "seu_usuario",
    "PWD" => "sua_senha",
    "CharacterSet" => "UTF-8"
);

$conn = sqlsrv_connect($serverName, $connectionInfo);

if (!$conn) {
    echo json_encode([
        'success' => false,
        'message' => 'Erro ao conectar com o banco de dados'
    ]);
    exit;
}

// Receber email
$email = isset($_POST['email']) ? trim($_POST['email']) : '';

// Validar email
if (empty($email) || !filter_var($email, FILTER_VALIDATE_EMAIL)) {
    echo json_encode([
        'success' => false,
        'message' => 'Email inválido'
    ]);
    exit;
}

// Verificar se email existe no banco
$sql = "SELECT Paciente_F, Nome_Paciente FROM Paciente WHERE Email = ? AND Ativo = 1";
$params = array($email);
$stmt = sqlsrv_query($conn, $sql, $params);

if ($stmt === false) {
    echo json_encode([
        'success' => false,
        'message' => 'Erro ao consultar banco de dados'
    ]);
    exit;
}

$paciente = sqlsrv_fetch_array($stmt, SQLSRV_FETCH_ASSOC);

if (!$paciente) {
    echo json_encode([
        'success' => false,
        'message' => 'Email não encontrado ou conta inativa'
    ]);
    exit;
}

// Gerar código de 6 dígitos
$codigo = sprintf('%06d', mt_rand(0, 999999));

// Salvar código na sessão (em produção, use banco de dados)
$_SESSION['codigo_recuperacao'] = $codigo;
$_SESSION['email_recuperacao'] = $email;
$_SESSION['cpf_recuperacao'] = $paciente['Paciente_F'];
$_SESSION['codigo_expiracao'] = time() + (10 * 60); // 10 minutos

// ==== ENVIO DE EMAIL ====
// Configurar PHPMailer ou função mail()
// Exemplo usando mail() (configure seu servidor SMTP adequadamente)

$assunto = "Código de Recuperação de Senha - Automacia";
$mensagem = "
<html>
<head>
    <style>
        body { font-family: Arial, sans-serif; }
        .container { max-width: 600px; margin: 0 auto; padding: 20px; }
        .header { background-color: #4CAF50; color: white; padding: 20px; text-align: center; }
        .content { padding: 20px; background-color: #f9f9f9; }
        .codigo { font-size: 32px; font-weight: bold; color: #4CAF50; text-align: center; padding: 20px; background-color: white; border: 2px solid #4CAF50; border-radius: 5px; margin: 20px 0; }
        .footer { padding: 20px; text-align: center; color: #666; font-size: 12px; }
    </style>
</head>
<body>
    <div class='container'>
        <div class='header'>
            <h1>Recuperação de Senha</h1>
        </div>
        <div class='content'>
            <p>Olá, <strong>" . htmlspecialchars($paciente['Nome_Paciente']) . "</strong></p>
            <p>Você solicitou a recuperação de senha da sua conta.</p>
            <p>Seu código de verificação é:</p>
            <div class='codigo'>" . $codigo . "</div>
            <p><strong>Este código expira em 10 minutos.</strong></p>
            <p>Se você não solicitou esta recuperação, ignore este email.</p>
        </div>
        <div class='footer'>
            <p>Sistema Automacia - Gerenciamento de Receitas Médicas</p>
        </div>
    </div>
</body>
</html>
";

$headers = "MIME-Version: 1.0" . "\r\n";
$headers .= "Content-type:text/html;charset=UTF-8" . "\r\n";
$headers .= "From: noreply@automacia.com.br" . "\r\n";

// Enviar email
$emailEnviado = mail($email, $assunto, $mensagem, $headers);

// Para desenvolvimento/teste, você pode comentar o envio real e apenas retornar sucesso
// $emailEnviado = true;
// echo "<!-- CÓDIGO DE TESTE: " . $codigo . " -->";

if ($emailEnviado) {
    echo json_encode([
        'success' => true,
        'message' => 'Código enviado com sucesso para ' . $email
    ]);
} else {
    echo json_encode([
        'success' => false,
        'message' => 'Erro ao enviar email. Tente novamente.'
    ]);
}

sqlsrv_close($conn);
?>