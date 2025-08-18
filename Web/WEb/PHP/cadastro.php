<?php
try {
	$serverName = "LAB21T-16\SQLEXPRESS";
	$connectionInfo = array( "Database"=>"Automacia", "UID"=>"sa", "PWD"=>"etesp");
	$conn = sqlsrv_connect( $serverName, $connectionInfo);
	if( $conn === false ) {
		die( print_r( sqlsrv_errors(), true));
	}

    $cpf = $_POST["cpf"];
    $senha = $_POST["senha"];
    $mail = $_POST["mail"];
    $nome = $_POST["nome"];
    $social = $_POST["social"];
    $csenha = $_POST["consenha"];

    if ($senha == $csenha) {
        try{ 

            $sql = "{CALL Registra_Paciente(?, ?, ?, ?, ?)}";
            $params = array($cpf, $senha, $mail, $nome, $social);

            $stmt = sqlsrv_query($conn, $sql, $params);

            if( $stmt == false ) {
                die( print_r( sqlsrv_errors(), true));
            }
            
            $retorno = null;

            do {
                while ($row = sqlsrv_fetch_array($stmt, SQLSRV_FETCH_BOTH)) {
                    $retorno = $row['Registra_Paciente_Retorno'] ?? null;
                }
            }while (sqlsrv_next_result($stmt));
        }catch(Exception $erro) {
            echo "ATENÇÃO - ERRO NA CONEXÃO: " . $erro->getMessage();
            die;
        }
    }else{
        echo "<script type='javascript'>alert('Cadastro realizado com Sucesso!');";
        $url = "http://localhost:8080/WEb/P%C3%A1ginas/login.html";
        header('Location: '.$url);;
    }
}catch(Exception $erro) {
	echo "ATENÇÃO - ERRO NA CONEXÃO: " . $erro->getMessage();
	die;
}

?>