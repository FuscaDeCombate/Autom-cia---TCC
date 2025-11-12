<?php
header('Content-Type: application/json; charset=utf-8');
include 'conexao.php';
session_start();

if (!($_SESSION['verificado'] ?? false)) {
    echo json_encode(['success' => false, 'message' => 'Código não verificado']);
    exit;
}

$novaSenha = trim($_POST['newPassword'] ?? '');
$confirmar = trim($_POST['confirmPassword'] ?? '');
$cpf       = $_SESSION['cpf_alvo'] ?? '';

if ($novaSenha === '' || $novaSenha !== $confirmar) {
    echo json_encode(['success' => false, 'message' => 'Senhas não conferem']);
    exit;
}

// Executa a procedure Alt_Senha_P no SQL Server
$sql = "{CALL Alt_Senha_P(?, ?)}";
$params = [$cpf, $novaSenha];
$stmt = sqlsrv_query($conn, $sql, $params);

if ($stmt) {
    $row = sqlsrv_fetch_array($stmt, SQLSRV_FETCH_ASSOC);
    $mensagem = $row['Alt_Senha_Retorno'] ?? 'Senha alterada';
    $sucesso = stripos($mensagem, 'sucesso') !== false;
    echo json_encode(['success' => $sucesso, 'message' => $mensagem]);
} else {
    echo json_encode(['success' => false, 'message' => 'Erro ao alterar senha']);
}
?>
