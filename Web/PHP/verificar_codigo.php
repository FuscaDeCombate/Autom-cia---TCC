<?php
header('Content-Type: application/json; charset=utf-8');
session_start();

$email = $_POST['email'] ?? '';
$code  = $_POST['code'] ?? '';

if (!isset($_SESSION['codigo_email'], $_SESSION['email_alvo'])) {
    echo json_encode(['success' => false, 'message' => 'Sessão expirada']);
    exit;
}

if ($email === $_SESSION['email_alvo'] && $code == $_SESSION['codigo_email']) {
    $_SESSION['verificado'] = true;
    echo json_encode(['success' => true, 'message' => 'Código verificado']);
} else {
    echo json_encode(['success' => false, 'message' => 'Código incorreto']);
}
?>
