<?php
try {
	session_start();
 
    $serverName = "XUXAOOG\SQLEXPRESS";
	$connectionInfo = array(
    "Database" => "Automacia",
    "UID" => "",
    "PWD" => "",
    "Encrypt" => false,
    "TrustServerCertificate" => true
);


	$conn = sqlsrv_connect( $serverName, $connectionInfo);
	if( $conn === false ) {
		die( print_r( sqlsrv_errors(), true));
	}

    $cpf = $_POST["cpf"];
    $senha = $_POST["senha"];
    $cpf_limp = str_replace([".", "-"], "", $cpf);

	$sql = "{CALL Login_Paciente (?, ?)}";
	$params = array($cpf_limp, $senha);

	$stm = sqlsrv_query($conn, $sql, $params);
    $num_colunas = sqlsrv_num_fields($stm);

    echo "<script>alert('$num_colunas');</script>";

	if($num_colunas == 8) {
		$_SESSION["guloso"] = $cpf_limp;
        $_SESSION["pocation"] = $senha;
        $url = "http://localhost/NeoBombonismo/index.php";
		header('Location: '.$url);
		die();
	}else{
        $mensagem = "Erro! Tente novamente";
		echo  "<script>alert('$mensagem');</script>";
        $url = "http://localhost/NeoBombonismo/Páginas/login.html";
		header('Location: '.$url);
		die();
	}
}catch(Exception $erro) {
	echo "ATENÇÃO - ERRO NA CONEXÃO: " . $erro->getMessage();
	die;
}

?>