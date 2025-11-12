package com.automacia.mobile.viewmodels;

import android.app.Application;

import androidx.annotation.NonNull;
import androidx.lifecycle.AndroidViewModel;
import androidx.lifecycle.LiveData;
import androidx.lifecycle.MutableLiveData;

import com.automacia.mobile.models.UsuarioDTO;
import com.automacia.mobile.services.RegisterService;
import com.automacia.mobile.utils.Utils;

/**
 * ViewModel para gerenciar o estado e lógica de negócio do cadastro
 * Sobrevive a mudanças de configuração e separa a lógica da UI
 */
public class RegisterViewModel extends AndroidViewModel {
    // Service
    private final RegisterService registerService;

    // ===== ESTADOS DE VALIDAÇÃO =====
    private final MutableLiveData<String> nomeError = new MutableLiveData<>(null);
    private final MutableLiveData<String> cpfError = new MutableLiveData<>(null);
    private final MutableLiveData<String> emailError = new MutableLiveData<>(null);
    private final MutableLiveData<String> telefoneError = new MutableLiveData<>(null);
    private final MutableLiveData<String> senhaError = new MutableLiveData<>(null);
    private final MutableLiveData<String> confirmacaoError = new MutableLiveData<>(null);

    // ===== ESTADOS DO FORMULÁRIO =====
    private final MutableLiveData<Boolean> isFormValid = new MutableLiveData<>(false);
    private final MutableLiveData<Boolean> isLoading = new MutableLiveData<>(false);
    private final MutableLiveData<Boolean> isAguardandoVerificacao = new MutableLiveData<>(false);

    // ===== DADOS DO USUÁRIO =====
    private final MutableLiveData<UsuarioDTO> usuarioTemporario = new MutableLiveData<>(null);
    private final MutableLiveData<String> emailParaVerificacao = new MutableLiveData<>(null);

    // ===== EVENTOS (Single Live Events) =====
    private final MutableLiveData<String> errorEvent = new MutableLiveData<>();
    private final MutableLiveData<String> successEvent = new MutableLiveData<>();
    private final MutableLiveData<Boolean> mostrarDialogoVerificacao = new MutableLiveData<>();
    private final MutableLiveData<Boolean> navegarParaLogin = new MutableLiveData<>();

    // ===== FLAGS DE VALIDAÇÃO INTERNA =====
    private boolean isNomeValido = false;
    private boolean isCpfValido = false;
    private boolean isEmailValido = false;
    private boolean isTelefoneValido = false;
    private boolean isSenhaValida = false;
    private boolean isConfirmacaoValida = false;

    // Armazena senha temporariamente para validação de confirmação
    private String senhaAtual = "";

    public RegisterViewModel(@NonNull Application application) {
        super(application);
        registerService = new RegisterService(application.getApplicationContext());
    }

    // ===== GETTERS PARA OBSERVAÇÃO NA ACTIVITY =====
    public LiveData<String> getNomeError() { return nomeError; }
    public LiveData<String> getCpfError() { return cpfError; }
    public LiveData<String> getEmailError() { return emailError; }
    public LiveData<String> getTelefoneError() { return telefoneError; }
    public LiveData<String> getSenhaError() { return senhaError; }
    public LiveData<String> getConfirmacaoError() { return confirmacaoError; }
    public LiveData<Boolean> getIsFormValid() { return isFormValid; }
    public LiveData<Boolean> getIsLoading() { return isLoading; }
    public LiveData<Boolean> getIsAguardandoVerificacao() { return isAguardandoVerificacao; }
    public LiveData<String> getErrorEvent() { return errorEvent; }
    public LiveData<String> getSuccessEvent() { return successEvent; }
    public LiveData<Boolean> getMostrarDialogoVerificacao() { return mostrarDialogoVerificacao; }
    public LiveData<Boolean> getNavegarParaLogin() { return navegarParaLogin; }
    public LiveData<String> getEmailParaVerificacao() { return emailParaVerificacao; }

    // ===== MÉTODOS DE VALIDAÇÃO =====

    public void validarNome(String nome) {
        String erro = Utils.validarNome(nome);
        nomeError.setValue(erro);
        isNomeValido = (erro == null);
        atualizarEstadoFormulario();
    }

    public void validarCpf(String cpfFormatado) {
        String erro = Utils.validarCpf(cpfFormatado);
        cpfError.setValue(erro);

        String cpfNumeros = Utils.extrairNumeros(cpfFormatado);
        isCpfValido = (erro == null && cpfNumeros.length() == 11);
        atualizarEstadoFormulario();
    }

    public void validarEmail(String email) {
        String emailTrim = email.trim();
        String erro = Utils.validarEmail(emailTrim);
        emailError.setValue(erro);
        isEmailValido = (erro == null);
        atualizarEstadoFormulario();
    }

    public void validarTelefone(String telefoneFormatado) {
        String erro = Utils.validarTelefone(telefoneFormatado);
        telefoneError.setValue(erro);

        String telefoneNumeros = Utils.extrairNumeros(telefoneFormatado);
        isTelefoneValido = (erro == null && telefoneNumeros.length() >= 10 && telefoneNumeros.length() <= 11);
        atualizarEstadoFormulario();
    }

    public void validarSenha(String senha) {
        senhaAtual = senha;
        String erro = Utils.validarSenha(senha);
        senhaError.setValue(erro);
        isSenhaValida = (erro == null);
        atualizarEstadoFormulario();
    }

    public void validarConfirmacao(String confirmacao) {
        String erro = Utils.validarConfirmacaoSenha(senhaAtual, confirmacao);
        confirmacaoError.setValue(erro);
        isConfirmacaoValida = (erro == null);
        atualizarEstadoFormulario();
    }

    private void atualizarEstadoFormulario() {
        boolean todosValidos = isNomeValido && isCpfValido && isEmailValido &&
                isTelefoneValido && isSenhaValida && isConfirmacaoValida;

        Boolean carregando = isLoading.getValue();
        Boolean aguardando = isAguardandoVerificacao.getValue();

        boolean podeHabilitar = todosValidos &&
                (carregando == null || !carregando) &&
                (aguardando == null || !aguardando);

        isFormValid.setValue(podeHabilitar);
    }

    // ===== LÓGICA DE CADASTRO =====

    public void realizarCadastro(String nome, String cpf, String email,
                                 String telefone, String senha) {

        // Coleta dados
        UsuarioDTO usuario = new UsuarioDTO();
        usuario.setNome(nome.trim());
        usuario.setCpf(Utils.extrairNumeros(cpf));
        usuario.setEmail(email.trim().toLowerCase());
        usuario.setTelefone(Utils.extrairNumeros(telefone));
        usuario.setSenha(senha);
        usuario.setNomeSocial(nome.trim().isEmpty() ? "" : nome.trim());

        usuarioTemporario.setValue(usuario);

        // Chama o service
        registerService.registrarUsuario(usuario, new RegisterService.RegisterCallback() {
            @Override
            public void onSuccess(String message) {
                isAguardandoVerificacao.setValue(true);
                emailParaVerificacao.setValue(usuario.getEmail());
                mostrarDialogoVerificacao.setValue(true);
                atualizarEstadoFormulario();
            }

            @Override
            public void onError(String error) {
                errorEvent.setValue(error);
                resetarEstadoCadastro();
            }

            @Override
            public void onLoading(boolean loading) {
                isLoading.setValue(loading);
                atualizarEstadoFormulario();
            }

            @Override
            public void onEmailVerificationSent(String email) {
                // Não usado aqui
            }
        });
    }

    // ===== VERIFICAÇÃO DE EMAIL =====

    public void verificarEmailConfirmado() {
        isLoading.setValue(true);

        registerService.processarLinkVerificacao(new RegisterService.RegisterCallback() {
            @Override
            public void onSuccess(String message) {
                isLoading.setValue(false);
                completarRegistroNoBanco();
            }

            @Override
            public void onError(String error) {
                isLoading.setValue(false);
                errorEvent.setValue("Email ainda não foi verificado. Clique no link do email e tente novamente.");
            }

            @Override
            public void onLoading(boolean loading) {
                // Não precisa
            }

            @Override
            public void onEmailVerificationSent(String email) {
                // Não usado
            }
        });
    }

    public void verificarEmailConfirmadoSilencioso() {
        registerService.processarLinkVerificacao(new RegisterService.RegisterCallback() {
            @Override
            public void onSuccess(String message) {
                successEvent.setValue("Email verificado! Finalizando cadastro...");
                completarRegistroNoBanco();
            }

            @Override
            public void onError(String error) {
                // Ignora erro na verificação silenciosa
            }

            @Override
            public void onLoading(boolean loading) {
                // Não mostra loading
            }

            @Override
            public void onEmailVerificationSent(String email) {
                // Não usado
            }
        });
    }

    public void reenviarEmailVerificacao() {
        registerService.reenviarLinkVerificacao(new RegisterService.RegisterCallback() {
            @Override
            public void onSuccess(String message) {
                successEvent.setValue(message);
            }

            @Override
            public void onError(String error) {
                errorEvent.setValue("Erro ao reenviar email: " + error);
            }

            @Override
            public void onLoading(boolean loading) {
                // Não precisa
            }

            @Override
            public void onEmailVerificationSent(String email) {
                // Email reenviado
            }
        });
    }

    private void completarRegistroNoBanco() {
        UsuarioDTO usuario = usuarioTemporario.getValue();
        if (usuario == null) {
            errorEvent.setValue("Erro: dados do usuário não encontrados");
            return;
        }

        isLoading.setValue(true);

        registerService.completarRegistroNoBanco(usuario, new RegisterService.DatabaseCallback() {
            @Override
            public void onSuccess(String message) {
                isLoading.setValue(false);
                successEvent.setValue(message);
                navegarParaLogin.setValue(true);
            }

            @Override
            public void onError(String error) {
                isLoading.setValue(false);
                errorEvent.setValue("Erro ao finalizar cadastro: " + error);
                resetarEstadoCadastro();
            }

            @Override
            public void onLoading(boolean loading) {
                isLoading.setValue(loading);
            }
        });
    }

    public void resetarEstadoCadastro() {
        isLoading.setValue(false);
        isAguardandoVerificacao.setValue(false);
        usuarioTemporario.setValue(null);
        atualizarEstadoFormulario();
    }

    // ===== GETTER PARA DADOS =====

    public UsuarioDTO getUsuarioTemporario() {
        return usuarioTemporario.getValue();
    }

    public boolean isProcessandoCadastro() {
        Boolean loading = isLoading.getValue();
        Boolean aguardando = isAguardandoVerificacao.getValue();
        return (loading != null && loading) || (aguardando != null && aguardando);
    }

    // ===== LIFECYCLE =====

    @Override
    protected void onCleared() {
        super.onCleared();
        if (registerService != null) {
            registerService.shutdown();
        }
    }
}
