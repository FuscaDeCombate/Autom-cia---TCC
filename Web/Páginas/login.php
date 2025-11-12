<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login - Sistema</title>
    <link rel="stylesheet" href="../CSS/login.css">
    <link rel="shortcut icon" href="../Imagem/file.png">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
</head>
<body>
    <div class="background-overlay"></div>
    
    <main>
        <div class="login-container">
            <form action="../PHP/login.php" method="post" id="loginForm">
                <div class="header">
                    <div class="logo-container">
                        <img src="../Imagem/file.png" alt="Logo">
                    </div>
                    <h1>BEM VINDO DE VOLTA</h1>
                    <p class="subtitle">Faça login para continuar</p>
                </div>

                <div class="form-content">
                    <div class="input-group">
                        <label for="cpf">CPF</label>
                        <div class="input-container">
                            <i class="fas fa-user input-icon"></i>
                            <input 
                                type="text" 
                                id="cpf"
                                name="cpf" 
                                class="form-input"
                                placeholder="000.000.000-00"
                                maxlength="14"
                                required
                            >
                        </div>
                    </div>

                    <div class="input-group">
                        <label for="senha">Senha</label>
                        <div class="input-container">
                            <i class="fas fa-lock input-icon"></i>
                            <input 
                                type="password" 
                                id="senha"
                                name="senha" 
                                class="form-input"
                                placeholder="Digite sua senha"
                                maxlength="32"
                                required
                            >
                            <button type="button" class="toggle-password" onclick="togglePassword()">
                                <i class="fas fa-eye" id="toggleIcon"></i>
                            </button>
                        </div>
                    </div>

                    <div class="options">
                        <div class="remember-me">
                            <input type="checkbox" id="remember" name="remember">
                            <label for="remember">Lembrar-me</label>
                        </div>
                        <a href="recsenha.html" class="forgot-password">Esqueci a senha</a>
                    </div>

                    <button type="submit" name="botaolog" class="login-btn">
                        <span class="btn-text">ENTRAR</span>
                        <i class="fas fa-arrow-right btn-icon"></i>
                    </button>

                    <div class="signup-link">
                        <p>Ainda não possui conta? 
                            <a href="cadastro.html">Cadastre-se aqui</a>
                        </p>
                    </div>
                </div>
            </form>
        </div>
    </main>

    <script>

        // Máscara para CPF
        function formatCPF(cpf) {
            cpf = cpf.replace(/\D/g, '');
            cpf = cpf.replace(/(\d{3})(\d)/, '$1.$2');
            cpf = cpf.replace(/(\d{3})(\d)/, '$1.$2');
            cpf = cpf.replace(/(\d{3})(\d{1,2})$/, '$1-$2');
            return cpf;
        }

        document.getElementById('cpf').addEventListener('input', function(e) {
            e.target.value = formatCPF(e.target.value);
        });

        // Toggle password visibility
        function togglePassword() {
            const passwordInput = document.getElementById('senha');
            const toggleIcon = document.getElementById('toggleIcon');
            
            if (passwordInput.type === 'password') {
                passwordInput.type = 'text';
                toggleIcon.classList.remove('fa-eye');
                toggleIcon.classList.add('fa-eye-slash');
            } else {
                passwordInput.type = 'password';
                toggleIcon.classList.remove('fa-eye-slash');
                toggleIcon.classList.add('fa-eye');
            }
        }

        // Form validation feedback
        document.getElementById('loginForm').addEventListener('submit', function(e) {
            const cpf = document.getElementById('cpf').value;
            const senha = document.getElementById('senha').value;
            
            if (cpf.replace(/\D/g, '').length !== 11) {
                e.preventDefault();
                alert('Por favor, digite um CPF válido.');
                return;
            }
            
            if (senha.length < 32) {
                e.preventDefault();
                alert('A senha deve ter pelo menos 32 caracteres.');
                return;
            }
        });

        // Loading state for button
        document.getElementById('loginForm').addEventListener('submit', function() {
            const btn = document.querySelector('.login-btn');
            const btnText = document.querySelector('.btn-text');
            const btnIcon = document.querySelector('.btn-icon');
            
            btnText.textContent = 'ENTRANDO...';
            btnIcon.classList.remove('fa-arrow-right');
            btnIcon.classList.add('fa-spinner', 'fa-spin');
            btn.disabled = true;
        });
    </script>
</body>
</html>

<?php
try {
	session_start();
    include("id.php");

	//$serverName = "LAB21T-04\SQLEXPRESS";
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
			$_SESSION["guloso"] = $cpf;
            $_SESSION["pocation"] = $senha;
            $url = "http://localhost:8080/NeoBombonismo/index.php";
			header('Location: '.$url);
			die();
		}else{
			echo  "<script>alert('Erro! Tente novamente);</script>";
            $url = "http://localhost:8080/NeoBombonismo/Páginas/login.php";
			header('Location: '.$url);
			die();
		}

  	}

}catch(Exception $erro) {
	echo "ATENÇÃO - ERRO NA CONEXÃO: " . $erro->getMessage();
	die;
}

?>