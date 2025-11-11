<?php
try {
/* 
    $serverName = "XUXAOOG\SQLEXPRESS";
$connectionInfo = array(
    "Database" => "Automacia",
    "UID" => "",
    "PWD" => "",
    "Encrypt" => false,
    "TrustServerCertificate" => true
);
*/

    $serverName = "XUXAOOG\SQLEXPRESS";
	$connectionInfo = array( "Database"=>"Automacia", "UID"=>"", "PWD"=>"");


	$conn = sqlsrv_connect( $serverName, $connectionInfo);
	if( $conn === false ) {
		die( print_r( sqlsrv_errors(), true));
	}

    $cpf = $_POST["cpf"];
    $senha = $_POST["senha"];
    $mail = $_POST["mail"];
    $nome = $_POST["nome"];
    $social = $_POST["social"];
    $fone = $_POST["fone"];
    $csenha = $_POST["consenha"];

    if ($senha == $csenha) {
        try{ 
            $cpf_limp = str_replace([".", "-"], "", $cpf);
           $sql = "{CALL Registra_Paciente (?, ?, ?, ?, ?, ?)}";
           $params = array($cpf_limp, $senha, $mail, $nome, $social, $fone);
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

            echo "<script type='javascript'>alert('Cadastro realizado com Sucesso!')<\script type='javascript'>;";
        $url = "../Páginas/login.html";
            header('Location: '.$url);;
        }catch(Exception $erro) {
            echo "ATENÇÃO - ERRO NA CONEXÃO: " . $erro->getMessage();
            die;
        }
    }else{
    }
}catch(Exception $erro) {
	echo "ATENÇÃO - ERRO NA CONEXÃO: " . $erro->getMessage();
	die;
}

?>