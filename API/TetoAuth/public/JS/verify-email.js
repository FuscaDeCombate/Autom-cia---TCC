// Import Firebase
import { initializeApp } from 'https://www.gstatic.com/firebasejs/10.7.1/firebase-app.js';
import { getAuth, applyActionCode } from 'https://www.gstatic.com/firebasejs/10.7.1/firebase-auth.js';

// Configuração do Firebase
const firebaseConfig = {
    apiKey: "AIzaSyD96SOsLl0EELtKhkrpjTliBR846PFqLL0",
    authDomain: "automacia-4ec6b.firebaseapp.com",
    projectId: "automacia-4ec6b",
    storageBucket: "automacia-4ec6b.firebasestorage.app",
    messagingSenderId: "897837676738",
    appId: "1:897837676738:web:f50777ffb8f8b8dade635b",
    measurementId: "G-34GZ8N7CQ1"
};

// Inicializar Firebase
const app = initializeApp(firebaseConfig);
const auth = getAuth(app);

// Elementos do DOM
const loadingState = document.getElementById('loading-state');
const successState = document.getElementById('success-state');
const errorState = document.getElementById('error-state');
const errorMessage = document.getElementById('error-message');

// Função para criar efeito ripple nos botões
function createRipple(e) {
    const button = e.currentTarget;
    const ripple = button.querySelector('.btn-ripple');
    
    if (!ripple) return;

    const rect = button.getBoundingClientRect();
    const size = Math.max(rect.width, rect.height);
    const x = e.clientX - rect.left - size / 2;
    const y = e.clientY - rect.top - size / 2;

    ripple.style.width = ripple.style.height = size + 'px';
    ripple.style.left = x + 'px';
    ripple.style.top = y + 'px';
    ripple.classList.add('active');

    setTimeout(() => {
        ripple.classList.remove('active');
    }, 600);
}

// Adicionar event listeners aos botões
document.addEventListener('DOMContentLoaded', () => {
    const buttons = document.querySelectorAll('.btn-primary, .btn-secondary');
    buttons.forEach(button => {
        button.addEventListener('click', createRipple);
    });
});

// Função para mostrar estado
function showState(state) {
    loadingState.classList.add('hidden');
    successState.classList.add('hidden');
    errorState.classList.add('hidden');

    switch(state) {
        case 'loading':
            loadingState.classList.remove('hidden');
            break;
        case 'success':
            successState.classList.remove('hidden');
            break;
        case 'error':
            errorState.classList.remove('hidden');
            break;
    }
}

// Função para verificar email
async function verifyEmail(oobCode) {
    try {
        // Aplicar o código de verificação
        await applyActionCode(auth, oobCode);
        
        // Sucesso - aguardar um pouco para melhor UX
        setTimeout(() => {
            showState('success');
        }, 1500);
        
    } catch (error) {
        console.error('Erro ao verificar email:', error);
        
        // Aguardar um pouco antes de mostrar erro
        setTimeout(() => {
            showState('error');
            
            // Mensagens de erro personalizadas
            if (error.code === 'auth/expired-action-code') {
                errorMessage.textContent = 'O link de verificação expirou. Por favor, solicite um novo email de verificação.';
            } else if (error.code === 'auth/invalid-action-code') {
                errorMessage.textContent = 'O link de verificação é inválido ou já foi usado.';
            } else if (error.code === 'auth/user-disabled') {
                errorMessage.textContent = 'Esta conta foi desativada. Entre em contato com o suporte.';
            } else if (error.code === 'auth/user-not-found') {
                errorMessage.textContent = 'Usuário não encontrado. A conta pode ter sido removida.';
            } else {
                errorMessage.textContent = 'Ocorreu um erro ao verificar seu email. Por favor, tente novamente mais tarde.';
            }
        }, 1500);
    }
}

// Inicializar verificação
function init() {
    // Pegar parâmetros da URL
    const urlParams = new URLSearchParams(window.location.search);
    const mode = urlParams.get('mode');
    const oobCode = urlParams.get('oobCode');

    // Verificar se é uma ação de verificação de email
    if (mode === 'verifyEmail' && oobCode) {
        // Mostrar loading
        showState('loading');
        
        // Verificar email
        verifyEmail(oobCode);
    } else {
        // Link inválido - mostrar erro imediatamente
        showState('error');
        errorMessage.textContent = 'Link de verificação inválido ou mal formatado.';
    }
}

// Inicializar quando o DOM estiver pronto
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
} else {
    init();
}