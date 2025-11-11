<?php
session_start();
if(!isset($_SESSION['guloso'])){
    header('Location: ../Páginas/login.html');
    exit;
}

// Conexão com o banco de dados
    $serverName = "XUXAOOG\SQLEXPRESS";
    $connectionInfo = array(
    "Database" => "Automacia",
    "UID" => "",
    "PWD" => "",
    "Encrypt" => false,
    "TrustServerCertificate" => true
);

$conn = sqlsrv_connect($serverName, $connectionInfo);
if ($conn === false) {
    die(print_r(sqlsrv_errors(), true));
}

$cpf = $_SESSION["guloso"];

// Recuperar o hash da senha do banco
$sql = "SELECT * FROM Paciente WHERE Paciente_F = ?";
$params = array($cpf);
$stm = sqlsrv_query($conn, $sql, $params);

if ($stm === false) {
    die(print_r(sqlsrv_errors(), true));
}

while ($row = sqlsrv_fetch_array($stm, SQLSRV_FETCH_ASSOC)) {
    $email = $row['Email'];
    $senha_hash = $row['Senha_Hash'];
    $nsocial = $row['Nome_Social'];
    $nome = $row['Nome_Paciente'];
    $fone = $row['Fone'];
}
?>

    <!DOCTYPE html>
    <html lang="pt-br">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Gerenciar Contas - Sistema</title>
        <link rel="stylesheet" href="../CSS/headerfoot.css">
        <link rel="stylesheet" href="../CSS/login.css">
        <link rel="shortcut icon" href="../Imagem/file.png">
        <link rel="stylesheet" href="../CSS/gconta.css">
        <script src="../script/particles.js"></script>
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
        <style>

            /* Responsividade */
@media (max-width: 768px) {
    .login-container {
        margin: 20px;
        padding: 30px 25px;
        max-width: none;
    }
    
    .header h1 {
        font-size: 20px;
    }
    
    .options {
        flex-direction: column;
        align-items: flex-start;
        gap: 15px;
    }
    
    /* Botões maiores no mobile */
    .login-btn {
        height: 55px;
        font-size: 18px;
        padding: 0 20px;
    }
    
    .action-btn {
        height: 55px;
        font-size: 18px;
        padding: 0 20px;
    }
    
    .modal-btn {
        height: 55px;
        font-size: 18px;
        padding: 15px 20px;
    }
}

@media (max-width: 480px) {
    .login-container {
        padding: 25px 20px;
    }
    
    .logo-container img {
        width: 60px;
        height: 60px;
    }
    
    .header h1 {
        font-size: 18px;
    }
    
    .form-input {
        height: 50px;
        font-size: 16px;
        padding: 0 45px 0 45px;
    }
    
    /* Botões ainda maiores em telas muito pequenas */
    .login-btn {
        height: 60px;
        font-size: 20px;
        font-weight: 700;
        letter-spacing: 1.5px;
    }
    
    .action-btn {
        height: 60px;
        font-size: 18px;
        font-weight: 700;
        min-height: 60px;
    }
    
    .modal-btn {
        height: 60px;
        font-size: 18px;
        font-weight: 700;
        padding: 18px 20px;
    }
    
    /* Aumentar espaçamento entre botões */
    .button-group {
        gap: 15px;
    }
    
    .modal-buttons {
        gap: 15px;
    }
    
    /* Aumentar área clicável dos ícones */
    .btn-icon,
    .modal-btn i {
        font-size: 20px;
    }
}

/* Extra small devices (menos de 375px) */
@media (max-width: 375px) {
    .login-btn {
        height: 65px;
        font-size: 18px;
    }
    
    .action-btn {
        height: 65px;
        font-size: 17px;
    }
    
    .modal-btn {
        height: 65px;
        font-size: 17px;
    }
    
    /* Empilhar botões verticalmente em telas muito pequenas */
    .button-group {
        flex-direction: column;
        width: 100%;
    }
    
    .button-group .action-btn {
        width: 100%;
    }
}

/* Landscape mode em celular */
@media (max-width: 768px) and (orientation: landscape) {
    .login-btn,
    .action-btn,
    .modal-btn {
        height: 50px;
        font-size: 16px;
    }
}

/* Melhorias específicas para botões de ação */
@media (max-width: 768px) {
    .action-btn span {
        font-weight: 700;
        letter-spacing: 1px;
    }
    
    .action-btn i {
        font-size: 20px;
    }
    
    /* Tornar área de toque maior */
    .action-btn {
        padding: 18px 25px;
        touch-action: manipulation;
        -webkit-tap-highlight-color: transparent;
    }
    
    .modal-btn {
        padding: 18px 25px;
        touch-action: manipulation;
        -webkit-tap-highlight-color: transparent;
    }
}

@media (max-width: 480px) {
    /* Aumentar gap entre ícone e texto */
    .action-btn {
        gap: 12px;
    }
    
    .modal-btn {
        gap: 12px;
    }
    
    /* Efeito visual ao tocar */
    .action-btn:active {
        transform: scale(0.98);
    }
    
    .modal-btn:active {
        transform: scale(0.98);
    }
}

            div#input-solidao{
                align_itens: center;
            }

            /* Estilos do Modal de Confirmação */
            .modal-overlay {
                display: none;
                position: fixed;
                top: 0;
                left: 0;
                width: 100%;
                height: 100%;
                background: rgba(0, 0, 0, 0.7);
                backdrop-filter: blur(5px);
                z-index: 9999;
                align-items: center;
                justify-content: center;
                animation: fadeIn 0.3s ease;
            }

            .modal-overlay.active {
                display: flex;
            }

            .modal-container {
                background: linear-gradient(135deg, #1a1a2e 0%, #16213e 100%);
                border-radius: 20px;
                padding: 40px;
                max-width: 450px;
                width: 90%;
                box-shadow: 0 20px 60px rgba(0, 0, 0, 0.5);
                border: 1px solid rgba(255, 255, 255, 0.1);
                animation: slideUp 0.3s ease;
                position: relative;
            }

            @keyframes fadeIn {
                from { opacity: 0; }
                to { opacity: 1; }
            }

            @keyframes slideUp {
                from {
                    transform: translateY(50px);
                    opacity: 0;
                }
                to {
                    transform: translateY(0);
                    opacity: 1;
                }
            }

            .modal-header {
                text-align: center;
                margin-bottom: 30px;
            }

            .modal-header i {
                font-size: 50px;
                color: #4a9eff;
                margin-bottom: 15px;
            }

            .modal-header h2 {
                color: #fff;
                font-size: 24px;
                margin-bottom: 10px;
            }

            .modal-header p {
                color: #b0b0b0;
                font-size: 14px;
            }

            .modal-input-group {
                margin-bottom: 30px;
            }

            .modal-input-group label {
                display: block;
                color: #fff;
                font-size: 14px;
                margin-bottom: 10px;
                font-weight: 500;
            }

            .modal-input-container {
                position: relative;
            }

            .modal-input-container input {
                width: 100%;
                padding: 15px 45px 15px 15px;
                background: rgba(255, 255, 255, 0.05);
                border: 2px solid rgba(255, 255, 255, 0.1);
                border-radius: 10px;
                color: #fff;
                font-size: 16px;
                transition: all 0.3s ease;
                box-sizing: border-box;
            }

            .modal-input-container input:focus {
                outline: none;
                border-color: #4a9eff;
                background: rgba(255, 255, 255, 0.08);
                box-shadow: 0 0 20px rgba(74, 158, 255, 0.2);
            }

            .modal-input-container input.error {
                border-color: #ff4757;
                animation: shake 0.5s ease;
            }

            @keyframes shake {
                0%, 100% { transform: translateX(0); }
                25% { transform: translateX(-10px); }
                75% { transform: translateX(10px); }
            }

            .modal-toggle-password {
                position: absolute;
                right: 15px;
                top: 50%;
                transform: translateY(-50%);
                color: #b0b0b0;
                cursor: pointer;
                transition: color 0.3s ease;
            }

            .modal-toggle-password:hover {
                color: #4a9eff;
            }

            .modal-error-message {
                display: none;
                color: #ff4757;
                font-size: 12px;
                margin-top: 8px;
                align-items: center;
                gap: 5px;
            }

            .modal-error-message.active {
                display: flex;
            }

            .modal-buttons {
                display: flex;
                gap: 15px;
                margin-top: 30px;
            }

            .modal-btn {
                flex: 1;
                padding: 15px;
                border: none;
                border-radius: 10px;
                font-size: 16px;
                font-weight: 600;
                cursor: pointer;
                transition: all 0.3s ease;
                display: flex;
                align-items: center;
                justify-content: center;
                gap: 10px;
            }

            .modal-btn-confirm {
                background: linear-gradient(135deg, #4a9eff 0%, #357abd 100%);
                color: #fff;
            }

            .modal-btn-confirm:hover:not(:disabled) {
                transform: translateY(-2px);
                box-shadow: 0 10px 30px rgba(74, 158, 255, 0.4);
            }

            .modal-btn-confirm:disabled {
                opacity: 0.5;
                cursor: not-allowed;
            }

            .modal-btn-cancel {
                background: rgba(255, 255, 255, 0.05);
                color: #fff;
                border: 2px solid rgba(255, 255, 255, 0.1);
            }

            .modal-btn-cancel:hover {
                background: rgba(255, 255, 255, 0.1);
                transform: translateY(-2px);
            }

        /* Mobile Menu Overlay Styles */
        .mobile-overlay {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0, 0, 0, 0.95);
            backdrop-filter: blur(10px);
            z-index: 9999;
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            opacity: 0;
            visibility: hidden;
            transition: opacity 0.3s ease, visibility 0.3s ease;
        }

        .mobile-overlay.active {
            opacity: 1;
            visibility: visible;
        }

        .mobile-overlay-close {
            position: absolute;
            top: 20px;
            right: 20px;
            width: 40px;
            height: 40px;
            background: transparent;
            border: none;
            cursor: pointer;
            padding: 0;
            z-index: 10000;
        }

        .mobile-overlay-close::before,
        .mobile-overlay-close::after {
            content: '';
            position: absolute;
            top: 50%;
            left: 50%;
            width: 30px;
            height: 3px;
            background: #66ccff;
            transition: all 0.3s ease;
        }

        .mobile-overlay-close::before {
            transform: translate(-50%, -50%) rotate(45deg);
        }

        .mobile-overlay-close::after {
            transform: translate(-50%, -50%) rotate(-45deg);
        }

        .mobile-overlay-close:hover::before,
        .mobile-overlay-close:hover::after {
            background: #fff;
        }

        .mobile-nav-menu {
            display: flex;
            flex-direction: column;
            gap: 30px;
            align-items: center;
            padding: 40px;
        }

        .mobile-nav-item {
            opacity: 0;
            transform: translateY(20px);
            transition: all 0.4s ease;
        }

        .mobile-overlay.active .mobile-nav-item {
            opacity: 1;
            transform: translateY(0);
        }

        .mobile-overlay.active .mobile-nav-item:nth-child(1) { transition-delay: 0.1s; }
        .mobile-overlay.active .mobile-nav-item:nth-child(2) { transition-delay: 0.2s; }
        .mobile-overlay.active .mobile-nav-item:nth-child(3) { transition-delay: 0.3s; }
        .mobile-overlay.active .mobile-nav-item:nth-child(4) { transition-delay: 0.4s; }

        .mobile-nav-item a {
            font-size: 2rem;
            font-weight: bold;
            color: #fff;
            text-decoration: none;
            text-transform: uppercase;
            letter-spacing: 2px;
            padding: 15px 30px;
            border-radius: 10px;
            transition: all 0.3s ease;
            display: block;
            position: relative;
            overflow: hidden;
        }

        .mobile-nav-item a::before {
            content: '';
            position: absolute;
            top: 0;
            left: -100%;
            width: 100%;
            height: 100%;
            background: linear-gradient(90deg, transparent, rgba(102, 204, 255, 0.3), transparent);
            transition: left 0.5s ease;
        }

        .mobile-nav-item a:hover {
            color: #66ccff;
            transform: scale(1.1);
        }

        .mobile-nav-item a:hover::before {
            left: 100%;
        }

        .mobile-menu {
            cursor: pointer;
            transition: transform 0.3s ease;
        }

        .mobile-menu:hover {
            transform: rotate(90deg);
        }
        </style>
    </head>
    <header>
        <div id="headerimg">
            <a href="Páginas/introdução.html" class="logo-link">
                <img src="../Imagem/file.png" alt="Logo" class="logo-img">
                <div class="logo-glow"></div>
            </a>
        </div>
        <div class="headerdiv nav-item" data-nav="download">
            <a href="../Páginas/download.html">
                <span>Baixar</span>
                <div class="nav-ripple"></div>
            </a>
        </div>
        <div class="headerdiv nav-item" data-nav="sobre">
            <a href="../Páginas/sobre.html">
                <span>Sobre</span>
                <div class="nav-ripple"></div>
            </a>
        </div>
        <div class="headerdiv nav-item" data-nav="faq">
            <a href="../Páginas/faq.html">
                <span>FAQ</span>
                <div class="nav-ripple"></div>
            </a>
        </div>
        <div class="headerdiv user-section">
            <a href="../index.php" class="user-btn">
                <img src="../Imagem/user.png" alt="Usuário">
                <div class="user-indicator"></div>
            </a>
            <img src="../Imagem/cardapio.png" id="bubulgue" alt="Menu" class="mobile-menu">
        </div>
    </header>

    <body>
     <!-- Mobile Menu Overlay -->
    <div class="mobile-overlay" id="mobileOverlay">
        <button class="mobile-overlay-close" id="closeOverlay" aria-label="Fechar menu"></button>
        <nav class="mobile-nav-menu">
            <div class="mobile-nav-item">
                <a href="../Páginas/download.html">Baixar</a>
            </div>
            <div class="mobile-nav-item">
                <a href="../Páginas/sobre.html">Sobre</a>
            </div>
            <div class="mobile-nav-item">
                <a href="../Páginas/faq.html">FAQ</a>
            </div>
            <div class="mobile-nav-item">
                <a href="../index.php">Minha Conta</a>
            </div>
        </nav>
    </div>
        <div class="background-overlay"></div>
        
        <main>
            <canvas id="particles-canvas"></canvas>
            
            <div class="login-container">
                <form method="post" id="contaForm">
                    <div class="header">
                        <div class="logo-container">
                            <img src="../Imagem/file.png" alt="Logo">
                        </div>
                        <h1>GERENCIAR CONTA</h1>
                        <p class="subtitle">Visualize e edite suas informações</p>
                    </div>

                    <div class="form-content">
<!-- Primeira linha -->
<div class="form-row">
    <div class="input-group">
        <label for="nome">Nome Completo</label>
        <div class="input-container">
            <i class="fas fa-user input-icon"></i>
            <input 
                type="text" 
                id="nome"
                name="nome" 
                class="form-input"
                placeholder="Seu nome completo"
                value="<?php echo $nome ?>"
                required
            >
        </div>
    </div>

    <div class="input-group">
        <label for="fone">Telefone</label>
        <div class="input-container">
            <i class="fas fa-phone input-icon"></i>
            <input 
                type="tel" 
                id="fone"
                name="fone" 
                class="form-input"
                placeholder="(00) 00000-0000"
                maxlength="15"
                value="<?php echo $fone ?>"
                required
            >
        </div>
    </div>
</div>

<!-- Segunda linha -->
<div class="form-row">
    <div class="input-group">
        <label for="nomes">Nome Social</label>
        <div class="input-container">
            <i class="fas fa-user input-icon"></i>
            <input 
                type="text" 
                id="nomes"
                name="nomes" 
                class="form-input"
                placeholder="Seu nome social"
                value="<?php echo $nsocial ?>"
            >
        </div>
    </div>

    <div class="input-group">
        <label for="email">E-mail</label>
        <div class="input-container">
            <i class="fas fa-envelope input-icon disabled-icon"></i>
            <input 
                type="email" 
                id="email"
                name="email" 
                class="form-input"
                placeholder="seu@email.com"
                value="<?php echo $email ?>"
            >
        </div>
    </div>
</div>

<!-- CPF - Abaixo dos campos anteriores -->
<div class="center-row">
    <div class="input-group center-input">
        <label for="cpf">CPF</label>
        <div class="input-container">
            <i class="fas fa-id-card input-icon disabled-icon"></i>
            <input 
                type="text" 
                id="cpf"
                name="cpf" 
                class="form-input"
                placeholder="000.000.000-00"
                value="<?php echo $cpf ?>"
                disabled
            >
        </div>
    </div>
</div>

<!-- Botões -->
<div class="button-group">
    <button type="button" class="action-btn btn-edit" id="editBtn" onclick="mostrarModalConfirmacao()">
        <i class="fas fa-save"></i>
        <span>SALVAR</span>
    </button>

    <button type="button" class="action-btn btn-cancel" onclick="cancelarAlteracoes()">
        <i class="fas fa-times"></i>
        <span>CANCELAR</span>
    </button>

    <button type="button" class="action-btn btn-exit" onclick="sairSistema()">
        <i class="fas fa-sign-out-alt"></i>
        <span>SAIR</span>
    </button>
</div>
                    </div>
                </form>
            </div>
        </main>

        <!-- Modal de Confirmação de Senha -->
        <div id="modalConfirmacao" class="modal-overlay">
            <div class="modal-container">
                <div class="modal-header">
                    <i class="fas fa-shield-alt"></i>
                    <h2>Confirme sua Senha</h2>
                    <p>Digite sua senha atual para confirmar as alterações</p>
                </div>

                <div class="modal-input-group">
                    <label for="senhaConfirmacao">Senha Atual</label>
                    <div class="modal-input-container">
                        <input 
                            type="password" 
                            id="senhaConfirmacao" 
                            placeholder="Digite sua senha atual"
                            autocomplete="current-password"
                        >
                        <i class="fas fa-eye modal-toggle-password" id="toggleModalPassword" onclick="toggleModalPassword()"></i>
                    </div>
                    <div class="modal-error-message" id="modalError">
                        <i class="fas fa-exclamation-circle"></i>
                        <span>Por favor, digite sua senha.</span>
                    </div>
                </div>

                <div class="modal-buttons">
                    <button type="button" class="modal-btn modal-btn-cancel" onclick="fecharModal()">
                        <i class="fas fa-times"></i>
                        <span>Cancelar</span>
                    </button>
                    <button type="button" class="modal-btn modal-btn-confirm" id="btnConfirmarModal" onclick="confirmarESalvar()">
                        <i class="fas fa-check"></i>
                        <span>Confirmar</span>
                    </button>
                </div>
            </div>
        </div>

        <script>
            // Máscara para CPF
            function formatCPF(cpf) {
                cpf = cpf.replace(/\D/g, '');
                cpf = cpf.replace(/(\d{3})(\d)/, '$1.$2');
                cpf = cpf.replace(/(\d{3})(\d)/, '$1.$2');
                cpf = cpf.replace(/(\d{3})(\d{1,2})$/, '$1-$2');
                return cpf;
            }

            // Máscara para telefone
            function formatTelefone(telefone) {
                telefone = telefone.replace(/\D/g, '');
                telefone = telefone.replace(/(\d{2})(\d)/, '($1) $2');
                telefone = telefone.replace(/(\d{5})(\d)/, '$1-$2');
                return telefone;
            }

            document.getElementById('fone').addEventListener('input', function(e) {
                e.target.value = formatTelefone(e.target.value);
            });

            document.getElementById('cpf').addEventListener('input', function(e) {
                e.target.value = formatCPF(e.target.value);
            });

            // Funções do Modal
            function mostrarModalConfirmacao() {
                // Validação básica antes de mostrar o modal
                const nome = document.getElementById('nome').value;
                const email = document.getElementById('email').value;
                const fone = document.getElementById('fone').value;

                if (!nome.trim()) {
                    alert('Nome é obrigatório!');
                    return;
                }

                if (!email.trim()) {
                    alert('Email é obrigatório!');
                    return;
                }

                if (fone && fone.replace(/\D/g, '').length < 10) {
                    alert('Por favor, digite um telefone válido.');
                    return;
                }

                // Mostra o modal
                document.getElementById('modalConfirmacao').classList.add('active');
                document.getElementById('senhaConfirmacao').focus();
                
                // Limpa erro anterior
                document.getElementById('modalError').classList.remove('active');
                document.getElementById('senhaConfirmacao').classList.remove('error');
            }

            function fecharModal() {
                document.getElementById('modalConfirmacao').classList.remove('active');
                document.getElementById('senhaConfirmacao').value = '';
                document.getElementById('modalError').classList.remove('active');
                document.getElementById('senhaConfirmacao').classList.remove('error');
            }

            function toggleModalPassword() {
                const input = document.getElementById('senhaConfirmacao');
                const icon = document.getElementById('toggleModalPassword');
                
                if (input.type === 'password') {
                    input.type = 'text';
                    icon.classList.remove('fa-eye');
                    icon.classList.add('fa-eye-slash');
                } else {
                    input.type = 'password';
                    icon.classList.remove('fa-eye-slash');
                    icon.classList.add('fa-eye');
                }
            }

            // Permitir Enter para confirmar no modal
            document.getElementById('senhaConfirmacao').addEventListener('keypress', function(e) {
                if (e.key === 'Enter') {
                    confirmarESalvar();
                }
            });

            // Fechar modal ao clicar fora
            document.getElementById('modalConfirmacao').addEventListener('click', function(e) {
                if (e.target === this) {
                    fecharModal();
                }
            });

            async function confirmarESalvar() {
                const senhaConfirmacao = document.getElementById('senhaConfirmacao').value;
                const btnConfirmar = document.getElementById('btnConfirmarModal');
                const modalError = document.getElementById('modalError');
                const inputSenha = document.getElementById('senhaConfirmacao');

                if (!senhaConfirmacao.trim()) {
                    inputSenha.classList.add('error');
                    modalError.classList.add('active');
                    return;
                }

                // Desabilita o botão e mostra loading
                btnConfirmar.disabled = true;
                btnConfirmar.querySelector('i').className = 'fas fa-spinner fa-spin';
                btnConfirmar.querySelector('span').textContent = 'Salvando...';

                try {
                    // Fecha o modal e executa o salvamento
                    fecharModal();
                    await salvarAlteracoes(senhaConfirmacao);
                    
                } catch (error) {
                    console.error('Erro ao salvar:', error);
                    alert('Erro ao salvar: ' + error.message);
                } finally {
                    // Restaura o botão
                    btnConfirmar.disabled = false;
                    btnConfirmar.querySelector('i').className = 'fas fa-check';
                    btnConfirmar.querySelector('span').textContent = 'Confirmar';
                }
            }

            async function salvarAlteracoes(senhaAtual) {
                try {
                    // Coleta os dados do formulário
                    const dados = {
                        nome: document.getElementById('nome').value,
                        email: document.getElementById('email').value,
                        fone: document.getElementById('fone').value,
                        nsocial: document.getElementById('nomes').value,
                        senha: senhaAtual, // Senha atual para validação
                        cpf: <?php echo json_encode($cpf); ?>
                    };

                    // Atualiza o botão para estado de loading
                    const btn = document.getElementById('editBtn');
                    const btnIcon = btn.querySelector('i');
                    const btnText = btn.querySelector('span');
                    
                    btnText.textContent = 'SALVANDO...';
                    btnIcon.className = 'fas fa-spinner fa-spin';
                    btn.disabled = true;

                    // Envia os dados para o PHP
                    const resultado = await enviaPHp('salvaralt.php', dados);
                    
                    if (resultado.sucesso) {
                        alert(resultado.mensagem || 'Dados salvos com sucesso!');
                        // Recarrega a página para mostrar os dados atualizados
                        window.location.reload();
                    } else {
                        alert('Erro: ' + (resultado.erro || 'Erro desconhecido'));
                    }

                } catch (error) {
                    console.error('Erro na função salvarAlteracoes:', error);
                    alert('Erro inesperado: ' + error.message);
                    
                } finally {
                    // Restaura o botão ao estado original
                    const btn = document.getElementById('editBtn');
                    const btnIcon = btn.querySelector('i');
                    const btnText = btn.querySelector('span');
                    
                    btnText.textContent = 'SALVAR';
                    btnIcon.className = 'fas fa-save';
                    btn.disabled = false;
                }
            }

            // Função auxiliar para envio
            async function enviaPHp(urlPHP, dadosFormulario) {
                try {
                    const formData = new FormData();
                    
                    for (const [campo, valor] of Object.entries(dadosFormulario)) {
                        formData.append(campo, valor);
                    }
                    
                    const response = await fetch(urlPHP, {
                        method: 'POST',
                        body: formData
                    });
                    
                    if (!response.ok) {
                        throw new Error(`Erro HTTP: ${response.status}`);
                    }
                    
                    const resultado = await response.json();
                    return resultado;
                    
                } catch (error) {
                    console.error('Erro ao enviar dados:', error);
                    return {
                        sucesso: false,
                        erro: error.message
                    };
                }
            }

            // Função para cancelar alterações
            function cancelarAlteracoes() {
                if (confirm('Tem certeza que deseja cancelar as alterações?')) {
                    const ogNome = <?php echo json_encode($nome); ?>;
                    const ogFone = <?php echo json_encode($fone); ?>;
                    const ogEmail = <?php echo json_encode($email); ?>;
                    const ogSocial = <?php echo json_encode($nsocial); ?>;

                    document.getElementById('nome').value = ogNome;
                    document.getElementById('fone').value = ogFone;
                    document.getElementById('email').value = ogEmail;
                    document.getElementById('nomes').value = ogSocial;
                    document.getElementById('senha').value = '';

                    document.querySelectorAll('.form-input').forEach(input => {
                        input.classList.remove('error', 'success');
                    });

                    alert('Alterações canceladas.');
                }
            }

            // Função para sair do sistema
            function sairSistema() {
                if (confirm('Tem certeza que deseja sair do sistema?')) {
                    window.location.replace('logout.php');
                }
            }

            // Validação visual do telefone
            document.getElementById('fone').addEventListener('blur', function() {
                const telefone = this.value;
                if (telefone && telefone.replace(/\D/g, '').length < 10) {
                    this.classList.add('error');
                    this.classList.remove('success');
                } else if (telefone) {
                    this.classList.remove('error');
                    this.classList.add('success');
                }
            });

            // Efeito visual nos campos desabilitados
            document.addEventListener('DOMContentLoaded', function() {
                const disabledInputs = document.querySelectorAll('input:disabled');
                disabledInputs.forEach(input => {
                    const tooltip = document.createElement('div');
                    tooltip.style.cssText = `
                        position: absolute;
                        background: rgba(0, 0, 0, 0.8);
                        color: white;
                        padding: 5px 10px;
                        border-radius: 4px;
                        font-size: 12px;
                        display: none;
                        z-index: 1000;
                        pointer-events: none;
                    `;
                    tooltip.textContent = 'Este campo não pode ser editado';
                    document.body.appendChild(tooltip);

                    input.addEventListener('mouseenter', function(e) {
                        tooltip.style.display = 'block';
                        tooltip.style.left = e.pageX + 'px';
                        tooltip.style.top = (e.pageY - 35) + 'px';
                    });

                    input.addEventListener('mouseleave', function() {
                        tooltip.style.display = 'none';
                    });
                });
            });

            // Aviso para campos obrigatórios
            document.getElementById('nome').addEventListener('blur', function() {
                if (!this.value.trim()) {
                    this.classList.add('error');
                } else {
                    this.classList.remove('error');
                    this.classList.add('success');
                }
            });

        // Mobile Menu Toggle
        const bubulgue = document.getElementById('bubulgue');
        const mobileOverlay = document.getElementById('mobileOverlay');
        const closeOverlay = document.getElementById('closeOverlay');

        bubulgue.addEventListener('click', () => {
            mobileOverlay.classList.add('active');
            document.body.style.overflow = 'hidden';
        });

        closeOverlay.addEventListener('click', () => {
            mobileOverlay.classList.remove('active');
            document.body.style.overflow = '';
        });

        // Close overlay when clicking outside menu
        mobileOverlay.addEventListener('click', (e) => {
            if (e.target === mobileOverlay) {
                mobileOverlay.classList.remove('active');
                document.body.style.overflow = '';
            }
        });

        // Close overlay when clicking on a link
        const mobileNavLinks = document.querySelectorAll('.mobile-nav-item a');
        mobileNavLinks.forEach(link => {
            link.addEventListener('click', () => {
                mobileOverlay.classList.remove('active');
                document.body.style.overflow = '';
            });
        });
        </script>
    </body>
    </html>