<?php
try {
    include("id.php");

	$serverName = "LAB21T-16\SQLEXPRESS";
	$connectionInfo = array( "Database"=>"Automacia", "UID"=>"sa", "PWD"=>"etesp");
	$conn = sqlsrv_connect( $serverName, $connectionInfo);
	if( $conn === false ) {
		die( print_r( sqlsrv_errors(), true));
	}

    $cpf = $_POST["cpf"];
    $senha = $_POST["senha"];

	$sql = "{CALL Login_Paciente (?, ?)}";
	$params = array($cpf, $senha);

	$stm = sqlsrv_query($conn, $sql, $params);

	while( $row = sqlsrv_fetch_array( $stm, SQLSRV_FETCH_BOTH) ) {
		$valor = $row['CPF'];
		$vsenha = $row['Senha_Paciente'];
		if($valor == $cpf && $vsenha == $senha ) {
			setcookie($valor);
			$login->isUserLoggedIn() = true;
			$url = "http://localhost:8080/WEb/index.html";
			header('Location: '.$url);
			die();
		}else{
			$url = "http://localhost:8080/WEb/P%C3%A1ginas/login.html";
			header('Location: '.$url);
			die();
		}

  	}

}catch(Exception $erro) {
	echo "ATENÇÃO - ERRO NA CONEXÃO: " . $erro->getMessage();
	die;
}

?>