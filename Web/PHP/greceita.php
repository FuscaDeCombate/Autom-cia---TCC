<?php
session_start();

// Verificar se está logado
if (!isset($_SESSION['guloso'])) {
    header('Location: ../Páginas/login.html');
    exit;
}

// Configurações
$receitas = [];
$erro = null;
$semReceitas = false;

try {
    // 🔧 CONFIGURAÇÃO DO BANCO
    $serverName = "XUXAOOG\\SQLEXPRESS"; // duplo \\ é obrigatório
    $connectionInfo = [
        "Database" => "Automacia",
        "TrustServerCertificate" => true,
        "CharacterSet" => "UTF-8"
    ];

    $conn = sqlsrv_connect($serverName, $connectionInfo);
    if ($conn === false) {
        $errors = sqlsrv_errors();
        throw new Exception("Erro de conexão: " . print_r($errors, true));
    }

    $cpf = $_SESSION["guloso"];

    // 🔍 EXECUTAR STORED PROCEDURE
    $sql = "{CALL Ver_Receita(?)}";
    $params = [$cpf];

    $stm = sqlsrv_query($conn, $sql, $params);
    if ($stm === false) {
        $errors = sqlsrv_errors();
        throw new Exception("Erro na consulta: " . print_r($errors, true));
    }

    // 🔄 PROCESSAR RESULTADOS
    while ($row = sqlsrv_fetch_array($stm, SQLSRV_FETCH_ASSOC)) {

        // Detecta retorno vazio da procedure
        if (isset($row['Ver_Receita_Retorno'])) {
            $semReceitas = true;
            break;
        }

        // Converter datas em strings legíveis (mesmo que venham como DateTime ou string)
        foreach (['Data_Receita', 'Data_Validade'] as $campo) {
            if (isset($row[$campo])) {
                if ($row[$campo] instanceof DateTime) {
                    $row[$campo] = $row[$campo]->format('Y-m-d\TH:i:s');
                } else {
                    // Forçar formato ISO mesmo se for string
                    $timestamp = strtotime($row[$campo]);
                    $row[$campo] = $timestamp ? date('Y-m-d\TH:i:s', $timestamp) : null;
                }
            } else {
                $row[$campo] = null;
            }
        }

        // Sanitizar tipos
        $row['ID_Receita'] = (int)($row['ID_Receita'] ?? 0);
        $row['Funcionar_Rec'] = (int)($row['Funcionar_Rec'] ?? 0);
        $row['Baixas'] = (int)($row['Baixas'] ?? 0);
        $row['Limite_Baixas'] = (int)($row['Limite_Baixas'] ?? 1);
        $row['Valido'] = (bool)($row['Valido'] ?? false);

        // Texto
        $row['Medicamento'] = trim((string)($row['Medicamento'] ?? ''));
        $row['Detalhes'] = trim((string)($row['Detalhes'] ?? ''));
        $row['Funcionar_Nome'] = trim((string)($row['Funcionar_Nome'] ?? ''));
        $row['Paciente_F'] = trim((string)($row['Paciente_F'] ?? ''));

        $receitas[] = $row;
    }

    sqlsrv_free_stmt($stm);
    sqlsrv_close($conn);

} catch (Exception $e) {
    $erro = $e->getMessage();
}
?>

<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Minhas Receitas - Automácia</title>
    <link rel="stylesheet" href="..\CSS\receita.css">
    <link rel="stylesheet" href="../CSS/headerfoot.css">
    <script src="../script/particles.js"></script>
    <link rel="shortcut icon" href="../Imagem/file.png">
    <style>
        footer {
            max-width: none;
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

    <!-- Animated Background -->
    <div class="animated-bg">
    <canvas id="particles-canvas"></canvas>
        <div class="floating-shapes">
            <div class="shape"></div>
            <div class="shape"></div>
            <div class="shape"></div>
            <div class="shape"></div>
            <div class="shape"></div>
        </div>
    </div>

    <!-- Loading Screen -->
    <div id="loading-screen">
        <div class="loader">
            <div class="loader-circle"></div>
            <div class="loader-text">Carregando receitas...</div>
        </div>
    </div>


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
            <img src="Imagem/cardapio.png" id="bubulgue" alt="Menu" class="mobile-menu">
        </div>
    </header>

    <!-- Main Content -->
    <main>
        

        <div class="main-container">
            <!-- Page Header -->
            <div class="page-header">
                <h1 class="page-title">Minhas Receitas</h1>
                <p class="page-subtitle">Gerencie e visualize suas prescrições médicas</p>

                <div class="search-container">
                    <input 
                        type="text" 
                        class="search-input" 
                        id="searchInput"
                        placeholder="Buscar receita ou medicamento..."
                    >
                    <button class="search-btn" onclick="filtrarReceitas()">
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
                        </svg>
                    </button>
                </div>
            </div>

            <!-- Recipes Container -->
            <div class="recipes-container">
                <!-- Recipes Sidebar (Left Column) -->
                <div class="recipes-sidebar">
                    <div class="sidebar-header">
                        <h3>Lista de Receitas</h3>
                        <span class="recipes-count" id="recipesCount">0 receitas</span>
                    </div>
                    <div class="recipes-list" id="recipesList">
                        <!-- Recipe cards will be inserted here by JavaScript -->
                    </div>
                </div>

                <!-- Recipe Viewer (Right Column) -->
                <div class="recipe-viewer">
                    <div id="receitaaumentada">
                        <div class="recipe-placeholder">
                            <div class="placeholder-icon">
                                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
                                </svg>
                            </div>
                            <h3>Selecione uma receita</h3>
                            <p>Escolha uma receita da lista ao lado para visualizar todos os detalhes</p>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Quick Actions -->
            <div class="quick-actions-recipes">
                <button class="quick-btn" onclick="imprimirReceita()">
                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" 
                            d="M17 17h2a2 2 0 002-2v-4a2 2 0 00-2-2H5a2 2 0 00-2 2v4a2 2 0 002 2h2m2 4h6a2 2 0 002-2v-4a2 2 0 00-2-2H9a2 2 0 00-2 2v4a2 2 0 002 2zm8-12V5a2 2 0 00-2-2H9a2 2 0 00-2 2v4h10z" />
                    </svg>
                    Imprimir
                </button>
                <button class="quick-btn" onclick="location.reload()">
                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
                    </svg>
                    Atualizar
                </button>
            </div>
        </div>
    </main>

    <footer>
        <div id="direitos">
            <img src="../Imagem/file.png" alt="Logo">
            <p>Todos os direitos reservados ao grupo Automácia co.</p>
        </div>
        <div class="spacer"></div>
        <div id="abas">
            <div class="footer-section">
                <p class="footer-title">ABAS PRINCIPAIS</p>
                <a href="Páginas/download.html">BAIXAR</a>
                <a href="Páginas/sobre.html">SOBRE</a>
                <a href="Páginas/faq.html">FAQ</a>
            </div>
            <div class="footer-section">
                <p class="footer-title">REDES SOCIAIS</p>
                <a href="#" aria-label="Twitter">X</a>
                <a href="#" aria-label="Instagram">Instagram</a>
                <a href="#" aria-label="Github">Github</a>
            </div>
        </div>
    </footer>

<script>
    // Debug: verificar dados do PHP
    console.log('=== DEBUG RECEITAS ===');
    console.log('Dados PHP (raw):', '<?php echo addslashes(json_encode($receitas)); ?>');
    console.log('Quantidade de receitas:', <?php echo count($receitas); ?>);
    console.log('Sem receitas:', <?php echo $semReceitas ? 'true' : 'false'; ?>);
    console.log('Erro:', '<?php echo addslashes($erro ?? ''); ?>');
    console.log('======================');

    // Dados das receitas vindos do PHP
    let receitasData = [];
    let receitaSelecionada = null;

    try {
        receitasData = <?php echo !empty($receitas) ? json_encode($receitas, JSON_UNESCAPED_UNICODE) : '[]'; ?>;
    } catch (e) {
        console.error('Erro ao parsear dados de receitas:', e);
        receitasData = [];
    }

    <?php if($erro): ?>
    console.error('Erro ao carregar receitas:', <?php echo json_encode($erro); ?>);
    setTimeout(() => {
        showNotification('Erro ao carregar receitas: <?php echo addslashes($erro); ?>', 'error');
    }, 100);
    <?php endif; ?>

    // Função para esconder loading
    function hideLoadingScreen() {
        const loading = document.getElementById('loading-screen');
        if (loading) {
            loading.style.opacity = '0';
            setTimeout(() => {
                loading.style.display = 'none';
            }, 500);
        }
    }

    // Função para mostrar notificação
    function showNotification(message, type = 'info') {
        const notification = document.createElement('div');
        notification.className = `notification ${type} show`;
        notification.innerHTML = `
            <div class="notification-content">
                <span>${message}</span>
                <button class="notification-close" onclick="this.parentElement.parentElement.remove()">×</button>
            </div>
        `;
        document.body.appendChild(notification);
        
        setTimeout(() => {
            notification.remove();
        }, 3000);
    }

    // Funções de formatação de data
    function formatarData(data) {
        try {
            if (!data) return '--/--/----';
            
            const d = new Date(data);
            
            if (isNaN(d.getTime())) {
                return '--/--/----';
            }
            
            return d.toLocaleDateString('pt-BR');
        } catch (error) {
            console.error('Erro ao formatar data:', error);
            return '--/--/----';
        }
    }

    function formatarDataCompleta(data) {
        try {
            if (!data) return 'Data não disponível';
            
            const d = new Date(data);
            
            if (isNaN(d.getTime())) {
                return 'Data inválida';
            }
            
            return d.toLocaleDateString('pt-BR', { 
                day: '2-digit', 
                month: 'long', 
                year: 'numeric' 
            });
        } catch (error) {
            console.error('Erro ao formatar data:', error);
            return 'Erro ao formatar data';
        }
    }

    // Renderizar lista de receitas na sidebar
    function renderizarListaReceitas(receitas = receitasData) {
        const lista = document.getElementById('recipesList');
        const count = document.getElementById('recipesCount');
        
        if (!lista || !count) {
            console.error('Elementos não encontrados');
            return;
        }
        
        count.textContent = `${receitas.length} ${receitas.length === 1 ? 'receita' : 'receitas'}`;
        
        if (receitas.length === 0) {
            lista.innerHTML = `
                <p style="text-align: center; padding: 2rem; color: rgba(255,255,255,0.6);">
                    Nenhuma receita encontrada
                </p>
            `;
            return;
        }
        
        try {
            lista.innerHTML = receitas.map(receita => {
                const dataFormatada = formatarData(receita.Data_Receita);
                const validadeFormatada = formatarData(receita.Data_Validade);
                const dataValidade = receita.Data_Validade ? new Date(receita.Data_Validade) : null;
                const isValido = receita.Valido && dataValidade && dataValidade > new Date();
                
                const baixas = parseInt(receita.Baixas) || 0;
                const limiteBaixas = parseInt(receita.Limite_Baixas) || 1;
                
                return `
                    <div class="recipe-card" onclick="selecionarReceita(${receita.ID_Receita})" id="card-${receita.ID_Receita}">
                        <div class="recipe-icon">
                            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
                            </svg>
                        </div>
                        <div class="recipe-info">
                            <h4>Receita #${receita.ID_Receita}</h4>
                            <div class="recipe-description">${receita.Medicamento || 'Medicamento não especificado'}</div>
                            <div class="recipe-doctor">Dr(a). CRM: ${receita.Funcionar_Rec || 'Não informado'}</div>
                        </div>
                        <div class="recipe-meta">
                            <div class="recipe-date">${dataFormatada}</div>
                            <div class="recipe-validity">Val: ${validadeFormatada}</div>
                            <div class="recipe-status ${isValido ? 'valid' : 'invalid'}">
                                <span class="status-dot"></span>
                                ${isValido ? 'Válida' : 'Expirada'}
                            </div>
                            <div class="recipe-usage">
                                <span class="usage-count">${baixas}/${limiteBaixas} usos</span>
                            </div>
                        </div>
                        <div class="recipe-arrow">
                            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
                            </svg>
                        </div>
                    </div>
                `;
            }).join('');
        } catch (error) {
            console.error('Erro ao renderizar lista:', error);
            lista.innerHTML = `
                <p style="text-align: center; padding: 2rem; color: #ff6b6b;">
                    Erro ao carregar receitas. Por favor, recarregue a página.
                </p>
            `;
        }
    }

    // Selecionar e exibir detalhes da receita
    function selecionarReceita(id) {
        try {
            const receita = receitasData.find(r => r.ID_Receita === id);
            if (!receita) {
                console.error('Receita não encontrada:', id);
                return;
            }
            
            receitaSelecionada = receita;
            
            // Atualizar classes active
            document.querySelectorAll('.recipe-card').forEach(card => {
                card.classList.remove('active');
            });
            
            const cardElement = document.getElementById(`card-${id}`);
            if (cardElement) {
                cardElement.classList.add('active');
            }
            
            // Renderizar detalhes
            renderizarDetalhesReceita(receita);
        } catch (error) {
            console.error('Erro ao selecionar receita:', error);
            showNotification('Erro ao carregar detalhes da receita', 'error');
        }
    }

    // Renderizar detalhes da receita no viewer
    function renderizarDetalhesReceita(receita) {
        const viewer = document.getElementById('receitaaumentada');
        
        if (!viewer) {
            console.error('Elemento viewer não encontrado');
            return;
        }
        
        try {
            // Validações seguras
            const dataValidade = receita.Data_Validade ? new Date(receita.Data_Validade) : null;
            const dataAtual = new Date();
            const isValido = receita.Valido && dataValidade && dataValidade > dataAtual;
            
            const baixas = parseInt(receita.Baixas) || 0;
            const limiteBaixas = parseInt(receita.Limite_Baixas) || 1;
            const porcentagemUso = limiteBaixas > 0 ? (baixas / limiteBaixas) * 100 : 0;
            const usosRestantes = Math.max(0, limiteBaixas - baixas);
            
            // Formatar datas com segurança
            const dataEmissao = receita.Data_Receita ? formatarDataCompleta(receita.Data_Receita) : 'Não informada';
            const validadeFormatada = receita.Data_Validade ? formatarDataCompleta(receita.Data_Validade) : 'Não informada';
            
            viewer.innerHTML = `
                <div class="recipe-content">
                    <div class="recipe-header">
                        <div class="recipe-title-section">
                            <h2>Receita #${receita.ID_Receita || 'S/N'}</h2>
                            <div class="recipe-badges">
                                <span class="badge ${isValido ? 'valid' : 'invalid'}">
                                    ${isValido ? '✓ Válida' : '✗ Expirada'}
                                </span>
                                ${usosRestantes > 0 ? 
                                    `<span class="badge priority">Usos disponíveis</span>` : 
                                    `<span class="badge priority high">Sem usos</span>`
                                }
                            </div>
                        </div>
                        <div class="recipe-actions">
                            <button class="action-btn" title="Imprimir" onclick="window.print()">
                                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 17h2a2 2 0 002-2v-4a2 2 0 00-2-2H5a2 2 0 00-2 2v4a2 2 0 002 2h2m2 4h6a2 2 0 002-2v-4a2 2 0 00-2-2H9a2 2 0 00-2 2v4a2 2 0 002 2zm8-12V5a2 2 0 00-2-2H9a2 2 0 00-2 2v4h10z" />
                                </svg>
                            </button>
                            <button class="action-btn" title="Compartilhar" onclick="compartilharReceita()">
                                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8.684 13.342C8.886 12.938 9 12.482 9 12c0-.482-.114-.938-.316-1.342m0 2.684a3 3 0 110-2.684m0 2.684l6.632 3.316m-6.632-6l6.632-3.316m0 0a3 3 0 105.367-2.684 3 3 0 00-5.367 2.684zm0 9.316a3 3 0 105.368 2.684 3 3 0 00-5.368-2.684z" />
                                </svg>
                            </button>
                        </div>
                    </div>
                    
                    <div class="recipe-details">
                        <div class="detail-section">
                            <h4>Informações Gerais</h4>
                            <div class="detail-grid">
                                <div class="detail-item">
                                    <span class="detail-label">Data de Emissão</span>
                                    <span class="detail-value">${dataEmissao}</span>
                                </div>
                                <div class="detail-item">
                                    <span class="detail-label">Validade</span>
                                    <span class="detail-value">${validadeFormatada}</span>
                                </div>
                                <div class="detail-item">
                                    <span class="detail-label">Médico Responsável</span>
                                    <span class="detail-value">CRM: ${receita.Funcionar_Rec || 'Não informado'}</span>
                                </div>
                                <div class="detail-item">
                                    <span class="detail-label">Status</span>
                                    <span class="detail-value" style="color: ${isValido ? '#00ff88' : '#ff6b6b'}">
                                        ${isValido ? 'Ativa' : 'Expirada'}
                                    </span>
                                </div>
                            </div>
                        </div>
                        
                        <div class="detail-section">
                            <h4>Medicamento Prescrito</h4>
                            <div class="medication-display">
                                <div class="medication-item">
                                    <div class="med-icon">
                                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19.428 15.428a2 2 0 00-1.022-.547l-2.387-.477a6 6 0 00-3.86.517l-.318.158a6 6 0 01-3.86.517L6.05 15.21a2 2 0 00-1.806.547M8 4h8l-1 1v5.172a2 2 0 00.586 1.414l5 5c1.26 1.26.367 3.414-1.415 3.414H4.828c-1.782 0-2.674-2.154-1.414-3.414l5-5A2 2 0 009 10.172V5L8 4z" />
                                        </svg>
                                    </div>
                                    <div class="med-details">
                                        <h5>${receita.Medicamento || 'Medicamento não especificado'}</h5>
                                        <div class="usage-progress">
                                            <div class="usage-bar">
                                                <div class="usage-fill" style="width: ${Math.min(porcentagemUso, 100)}%"></div>
                                            </div>
                                            <span class="usage-text">
                                                ${baixas} de ${limiteBaixas} usos realizados 
                                                (${usosRestantes} ${usosRestantes === 1 ? 'uso restante' : 'usos restantes'})
                                            </span>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        
                        ${receita.Detalhes && receita.Detalhes.trim() !== '' ? `
                        <div class="detail-section">
                            <h4>Instruções de Uso</h4>
                            <div class="instructions">
                                <p>${receita.Detalhes}</p>
                            </div>
                        </div>
                        ` : ''}
                    </div>
                </div>
            `;
        } catch (error) {
            console.error('Erro ao renderizar detalhes:', error);
            viewer.innerHTML = `
                <div class="recipe-placeholder">
                    <div class="placeholder-icon">
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
                        </svg>
                    </div>
                    <h3>Erro ao carregar receita</h3>
                    <p>Não foi possível exibir os detalhes desta receita</p>
                </div>
            `;
        }
    }

    // Função de filtro
    function filtrarReceitas() {
        try {
            const termo = document.getElementById('searchInput').value.toLowerCase();
            const receitasFiltradas = receitasData.filter(receita => {
                return (receita.Medicamento && receita.Medicamento.toLowerCase().includes(termo)) ||
                    (receita.ID_Receita && receita.ID_Receita.toString().includes(termo)) ||
                    (receita.Detalhes && receita.Detalhes.toLowerCase().includes(termo));
            });
            renderizarListaReceitas(receitasFiltradas);
        } catch (error) {
            console.error('Erro ao filtrar receitas:', error);
        }
    }

    function imprimirReceita() {
    if (!receitaSelecionada) {
        showNotification('Selecione uma receita para imprimir', 'warning');
        return;
    }

    // Espera um pequeno delay para o navegador aplicar o CSS de print
    setTimeout(() => {
        window.print();
    }, 200);
}

    // Função para compartilhar receita
    function compartilharReceita() {
        if (!receitaSelecionada) return;
        
        try {
            const texto = `Receita #${receitaSelecionada.ID_Receita}\n` +
                        `Medicamento: ${receitaSelecionada.Medicamento}\n` +
                        `Validade: ${formatarDataCompleta(receitaSelecionada.Data_Validade)}`;
            
            if (navigator.share) {
                navigator.share({
                    title: 'Receita Médica',
                    text: texto
                }).catch(err => console.log('Erro ao compartilhar:', err));
            } else {
                navigator.clipboard.writeText(texto);
                showNotification('Receita copiada para área de transferência!', 'success');
            }
        } catch (error) {
            console.error('Erro ao compartilhar:', error);
            showNotification('Erro ao compartilhar receita', 'error');
        }
    }

    // Inicialização principal
    function inicializarPagina() {
        try {
            console.log('Inicializando página...');
            console.log('Tipo de receitasData:', typeof receitasData);
            console.log('É array?', Array.isArray(receitasData));
            console.log('Receitas carregadas:', Array.isArray(receitasData) ? receitasData.length : 0);
            
            // Garantir que receitasData é um array
            if (!Array.isArray(receitasData)) {
                console.warn('receitasData não é um array, convertendo...');
                receitasData = [];
            }
            
            // Renderizar lista
            renderizarListaReceitas();
            
            // Configurar busca em tempo real
            const searchInput = document.getElementById('searchInput');
            if (searchInput) {
                searchInput.addEventListener('input', filtrarReceitas);
            }
            
            // Configurar menu mobile
            const bubulgue = document.getElementById('bubulgue');
            const mobileOverlay = document.getElementById('mobileOverlay');
            const closeOverlay = document.getElementById('closeOverlay');
            
            if (bubulgue && mobileOverlay && closeOverlay) {
                bubulgue.addEventListener('click', () => {
                    mobileOverlay.classList.add('active');
                    document.body.style.overflow = 'hidden';
                });

                closeOverlay.addEventListener('click', () => {
                    mobileOverlay.classList.remove('active');
                    document.body.style.overflow = '';
                });

                mobileOverlay.addEventListener('click', (e) => {
                    if (e.target === mobileOverlay) {
                        mobileOverlay.classList.remove('active');
                        document.body.style.overflow = '';
                    }
                });
            }
            
            // Esconder loading
            hideLoadingScreen();
            
            console.log('Página inicializada com sucesso!');
        } catch (error) {
            console.error('Erro ao inicializar página:', error);
            hideLoadingScreen();
            showNotification('Erro ao carregar página. Por favor, recarregue.', 'error');
        }
    }

    // Event listeners
    document.addEventListener('DOMContentLoaded', inicializarPagina);

    // Fallback caso DOMContentLoaded já tenha disparado
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', inicializarPagina);
    } else {
        inicializarPagina();
    }
    </script>

</body>
</html>