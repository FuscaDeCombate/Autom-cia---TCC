<?php
session_start();

// Verifica se está logado
if(!isset($_SESSION['guloso'])){
    echo json_encode([
        'sucesso' => false,
        'erro' => 'Sessão expirada. Faça login novamente.'
    ]);
    exit;
}

// Verifica se é uma requisição POST
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    echo json_encode([
        'sucesso' => false,
        'erro' => 'Método não permitido'
    ]);
    exit;
}

// Captura os dados enviados
$cpf = $_POST['cpf'] ?? '';
$senha = $_POST['senha'] ?? '';
$email = $_POST['email'] ?? '';
$nome = $_POST['nome'] ?? '';
$nomeSocial = $_POST['nsocial'] ?? '';
$fone = $_POST['fone'] ?? '';

// Validação básica dos campos obrigatórios
if (empty($cpf) || empty($senha) || empty($email) || empty($nome) || empty($fone)) {
    echo json_encode([
        'sucesso' => false,
        'erro' => 'Todos os campos obrigatórios devem ser preenchidos'
    ]);
    exit;
}

// Conexão com o banco de dados

$serverName = "XUXAOOG\SQLEXPRESS";
$connectionInfo = array( "Database"=>"Automacia", "UID"=>"", "PWD"=>"");

$conn = sqlsrv_connect($serverName, $connectionInfo);

if ($conn === false) {
    echo json_encode([
        'sucesso' => false,
        'erro' => 'Erro ao conectar com o banco de dados: ' . print_r(sqlsrv_errors(), true)
    ]);
    exit;
}

try {
    // Prepara os parâmetros para a procedure
    $params = array(
        array($cpf, SQLSRV_PARAM_IN),
        array($senha, SQLSRV_PARAM_IN),
        array($email, SQLSRV_PARAM_IN),
        array($nome, SQLSRV_PARAM_IN),
        array($nomeSocial, SQLSRV_PARAM_IN),
        array($fone, SQLSRV_PARAM_IN)
    );
    
    // Executa a procedure
    $sql = "{CALL Alt_Paciente(?, ?, ?, ?, ?, ?)}";
    $stmt = sqlsrv_query($conn, $sql, $params);
    
    if ($stmt === false) {
        throw new Exception('Erro ao executar a procedure: ' . print_r(sqlsrv_errors(), true));
    }
    
    // Captura o resultado da procedure
    $mensagem = '';
    
    // Avança para o primeiro resultado (se houver)
    if (sqlsrv_fetch($stmt)) {
        // Tenta obter o valor da primeira coluna
        $mensagem = sqlsrv_get_field($stmt, 0);
    }
    
    // Se não conseguiu capturar, tenta de outra forma
    if (empty($mensagem)) {
        sqlsrv_next_result($stmt);
        if (sqlsrv_fetch($stmt)) {
            $mensagem = sqlsrv_get_field($stmt, 0);
        }
    }
    
    // Se ainda não tem mensagem, define uma padrão
    if (empty($mensagem)) {
        $mensagem = 'Dados alterados com sucesso';
    }
    
    // Libera os recursos
    sqlsrv_free_stmt($stmt);
    sqlsrv_close($conn);
    
    // Verifica se a alteração foi bem-sucedida
    // Ajuste a verificação conforme a mensagem real retornada pela procedure
    if (stripos($mensagem, 'sucesso') !== false || stripos($mensagem, 'alterado') !== false) {
        echo json_encode([
            'sucesso' => true,
            'mensagem' => $mensagem
        ]);
    } else {
        echo json_encode([
            'sucesso' => false,
            'erro' => $mensagem
        ]);
    }
    
} catch (Exception $e) {
    if ($conn) {
        sqlsrv_close($conn);
    }
    echo json_encode([
        'sucesso' => false,
        'erro' => $e->getMessage()
    ]);
}
?>