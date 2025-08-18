<?php

use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\Exception;

require 'Bliblioteca\PHPMailer\src\Exception.php';
require 'Bliblioteca\PHPMailer\src\PHPMailer.php';
require 'Bliblioteca\PHPMailer\src\SMTP.php';

try {
	$serverName = "LAB21T-16\SQLEXPRESS";
	$connectionInfo = array( "Database"=>"Automacia", "UID"=>"sa", "PWD"=>"etesp");
	$conn = sqlsrv_connect( $serverName, $connectionInfo);
	if( $conn === false ) {
		die( print_r( sqlsrv_errors(), true));
	}

    $email = $_POST["email"];

	$sql = "SELECT * FROM Paciente WHERE Email = ?";
	$params = array($email);

	$stm = sqlsrv_query($conn, $sql, $params);

	while( $row = sqlsrv_fetch_array( $stm, SQLSRV_FETCH_BOTH) ) {
		$valor = $row['Email'];
		if($valor == $email ) {
            $mail = new PHPMailer(true);
            $mail->isSMTP();        
            $mail->SMTPAuth = true; 
            $mail->Username  = 'tomazturbando878@gmail.com';
            $mail->Password  = 'lozoiuiopynbnoob';
            $mail->SMTPSecure = 'tls';
            $mail->SMTPOptions = array(
                'ssl' => array(
                    'verify_peer' => false,
                    'verify_peer_name' => false,
                    'allow_self_signed' => true
                )
            );
            $mail->Host = 'smtp.gmail.com';
            $mail->Port = 587;
            $mail->setFrom('tomazturbando878@gmail.com', 'Automacia');
            $mail->addAddress($email, 'Paciente Guloso');
            $mail->isHTML(true); 
            $mail->Subject = 'Recuperar senha';
            $mail->Body    = 'Este é o corpo da mensagem <b>Olá em negrito!</b>';
            $mail->AltBody = 'Este é o cortpo da mensagem para clientes de e-mail que não reconhecem HTML';
            // Enviar
            $mail->send();
            echo "<script type='javascript'>alert('Email enviado com Sucesso!');";
            $url = "http://localhost:8080/WEb/P%C3%A1ginas/login.html";
			header('Location: '.$url);
			die();
		}else{
			$url = "http://localhost/WEb/P%C3%A1ginas/recsenha.html";
			header('Location: '.$url);
			die();
		}

  	}

}catch(Exception $erro) {
	echo "ATENÇÃO - ERRO NA CONEXÃO: " . $erro->getMessage();
	die;
}

?>