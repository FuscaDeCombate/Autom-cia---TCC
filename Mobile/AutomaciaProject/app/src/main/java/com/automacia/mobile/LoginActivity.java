package com.automacia.mobile;

import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.text.Editable;
import android.text.TextWatcher;
import android.view.View;
import android.widget.TextView;
import android.widget.Toast;

import androidx.activity.EdgeToEdge;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;

import com.automacia.mobile.dialogs.ConnectionErrorDialog;
import com.automacia.mobile.models.UsuarioDTO;
import com.automacia.mobile.services.LoginService;
import com.automacia.mobile.utils.Utils;
import com.automacia.mobile.watchers.CpfMaskWatcher;
import com.google.android.material.button.MaterialButton;
import com.google.android.material.checkbox.MaterialCheckBox;
import com.google.android.material.textfield.TextInputEditText;
import com.google.android.material.textfield.TextInputLayout;

/**
 * Activity responsável pelo login de usuários
 * Implementa validações em tempo real usando Utils e autenticação via banco de dados
 */
public class LoginActivity extends AppCompatActivity {

    // Views
    private TextInputEditText editCpf, editSenha;
    private TextInputLayout layoutCpf, layoutSenha;
    private MaterialButton btnLogin, btnGoogle, btnFacebook;
    private MaterialCheckBox checkboxLembrar;
    private TextView txtEsqueciSenha, txtCadastro;

    // SharedPreferences para lembrar CPF
    private SharedPreferences preferences;
    private static final String PREF_NAME = "LoginPrefs";
    private static final String KEY_REMEMBER_CPF = "remember_cpf";
    private static final String KEY_SAVED_CPF = "saved_cpf";

    // Flags de validação
    private boolean isCpfValid = false;
    private boolean isSenhaValid = false;
    private static final int FORGOT_PASSWORD_REQUEST = 1001;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        EdgeToEdge.enable(this);
        setContentView(R.layout.activity_login);

        setupWindowInsets();
        initializeViews();
        setupValidators();
        setupClickListeners();
        loadSavedPreferences();
        testarConexaoBanco();
    }

    /**
     * Testa conexão com banco de dados antes de permitir login
     */
    private void testarConexaoBanco() {
        // Desabilitar interação durante teste
        setUIEnabled(false);
        showToast("Verificando conexão...");

        LoginService.testarConexaoAsync(new LoginService.LoginCallback() {
            @Override
            public void onSuccess(UsuarioDTO usuario) {
                runOnUiThread(() -> {
                    // Habilitar UI após sucesso
                    setUIEnabled(true);
                    showToast("Conexão estabelecida!");
                });
            }

            @Override
            public void onError(String mensagem) {
                runOnUiThread(() -> {
                    // Manter UI desabilitada e mostrar dialog
                    showConnectionErrorDialog(mensagem);
                });
            }
        });
    }

    /**
     * Mostra dialog de erro de conexão com opção de tentar novamente
     */
    private void showConnectionErrorDialog(String errorMessage) {
        ConnectionErrorDialog dialog = new ConnectionErrorDialog(this);

        // Determinar tipo de erro baseado na mensagem
        ConnectionErrorDialog.DatabaseErrorType errorType =
                determineErrorType(errorMessage);

        dialog.setDatabaseErrorType(errorType)
                .setErrorDetails(errorMessage)
                .showTechnicalDetails(true) // Mostra detalhes técnicos
                .setOnRetryListener(() -> {
                    // Tentar conectar novamente
                    testarConexaoBanco();
                })
                .setOnCancelListener(() -> {
                    // Fechar o app ou voltar
                    showToast("Não é possível continuar sem conexão");
                    finish(); // Fecha a activity
                });

        dialog.setCancelable(false); // Não permite fechar tocando fora
        dialog.show();
    }

    /**
     * Determina o tipo de erro baseado na mensagem
     */
    private ConnectionErrorDialog.DatabaseErrorType determineErrorType(String errorMessage) {
        String msg = errorMessage.toLowerCase();

        if (msg.contains("timeout") || msg.contains("tempo")) {
            return ConnectionErrorDialog.DatabaseErrorType.CONNECTION_TIMEOUT;
        } else if (msg.contains("autenticação") || msg.contains("login failed") ||
                msg.contains("authentication")) {
            return ConnectionErrorDialog.DatabaseErrorType.AUTHENTICATION_FAILED;
        } else if (msg.contains("database") && msg.contains("not found")) {
            return ConnectionErrorDialog.DatabaseErrorType.DATABASE_NOT_FOUND;
        } else if (msg.contains("network") || msg.contains("rede") ||
                msg.contains("conexão") || msg.contains("host")) {
            return ConnectionErrorDialog.DatabaseErrorType.NETWORK_ERROR;
        } else if (msg.contains("query") || msg.contains("sql")) {
            return ConnectionErrorDialog.DatabaseErrorType.QUERY_ERROR;
        }

        return ConnectionErrorDialog.DatabaseErrorType.UNKNOWN;
    }

    /**
     * Habilita/desabilita toda a UI
     */
    private void setUIEnabled(boolean enabled) {
        editCpf.setEnabled(enabled);
        editSenha.setEnabled(enabled);
        btnLogin.setEnabled(enabled && isCpfValid && isSenhaValid);
        btnGoogle.setEnabled(enabled);
        btnFacebook.setEnabled(enabled);
        checkboxLembrar.setEnabled(enabled);
        txtEsqueciSenha.setEnabled(enabled);
        txtCadastro.setEnabled(enabled);

        // Altera opacidade visual
        float alpha = enabled ? 1.0f : 0.5f;
        editCpf.setAlpha(alpha);
        editSenha.setAlpha(alpha);
        btnGoogle.setAlpha(alpha);
        btnFacebook.setAlpha(alpha);
    }

    /**
     * Configura as margens para telas edge-to-edge
     */
    private void setupWindowInsets() {
        ViewCompat.setOnApplyWindowInsetsListener(findViewById(R.id.main), (v, insets) -> {
            Insets systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars());
            v.setPadding(systemBars.left, systemBars.top, systemBars.right, systemBars.bottom);
            return insets;
        });

        View mainView = findViewById(R.id.main);
        Utils.applyGradientBackground(mainView);
    }

    /**
     * Inicializa todas as views
     */
    private void initializeViews() {
        // TextInputLayouts e EditTexts
        layoutCpf = findViewById(R.id.layoutCPF);
        layoutSenha = findViewById(R.id.layoutSenha);
        editCpf = findViewById(R.id.editCpf);
        editSenha = findViewById(R.id.editSenha);

        // Botões
        btnLogin = findViewById(R.id.btnLogin);
        btnGoogle = findViewById(R.id.btnGoogle);
        btnFacebook = findViewById(R.id.btnFacebook);

        // Outros componentes
        checkboxLembrar = findViewById(R.id.checkboxLembrar);
        txtEsqueciSenha = findViewById(R.id.txtEsqueciSenha);
        txtCadastro = findViewById(R.id.txtCadastro);

        // SharedPreferences
        preferences = getSharedPreferences(PREF_NAME, MODE_PRIVATE);

        // Estado inicial do botão
        updateLoginButtonState();
    }

    /**
     * Configura os validadores em tempo real para todos os campos
     */
    private void setupValidators() {
        setupCpfValidator();
        setupSenhaValidator();
    }

    /**
     * Validador para o campo CPF com máscara e validação usando Utils
     */
    private void setupCpfValidator() {
        // Aplica máscara de CPF
        editCpf.addTextChangedListener(new CpfMaskWatcher(editCpf));

        // Validação do CPF usando Utils
        editCpf.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {}

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                String erro = Utils.validarCpf(s.toString());
                layoutCpf.setError(erro);

                // Considera válido apenas se não há erro E tem 11 dígitos
                String cpfNumeros = Utils.extrairNumeros(s.toString());
                isCpfValid = (erro == null && cpfNumeros.length() == 11);

                updateLoginButtonState();
            }

            @Override
            public void afterTextChanged(Editable s) {}
        });
    }

    /**
     * Validador para o campo Senha usando Utils
     */
    private void setupSenhaValidator() {
        editSenha.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {}

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                String erro = Utils.validarSenha(s.toString());
                layoutSenha.setError(erro);
                isSenhaValid = (erro == null);
                updateLoginButtonState();
            }

            @Override
            public void afterTextChanged(Editable s) {}
        });
    }

    /**
     * Configura os listeners dos botões
     */
    private void setupClickListeners() {
        btnLogin.setOnClickListener(v -> performLogin());

        btnGoogle.setOnClickListener(v -> performGoogleLogin());

        btnFacebook.setOnClickListener(v -> performFacebookLogin());

        txtEsqueciSenha.setOnClickListener(v -> handleForgotPassword());

        txtCadastro.setOnClickListener(v -> navigateToRegister());

        checkboxLembrar.setOnCheckedChangeListener((buttonView, isChecked) -> {
            saveRememberPreference(isChecked);
        });
    }

    /**
     * Atualiza o estado do botão de login baseado nas validações
     */
    private void updateLoginButtonState() {
        boolean isEnabled = isCpfValid && isSenhaValid;
        btnLogin.setEnabled(isEnabled);

        // Altera aparência visual
        btnLogin.setAlpha(isEnabled ? 1.0f : 0.6f);
    }

    /**
     * Realiza o login do usuário via banco de dados
     */
    private void performLogin() {
        // Validação final usando Utils
        if (!validarTodosOsCampos()) {
            showToast("Por favor, corrija os erros antes de continuar");
            return;
        }

        String cpf = Utils.extrairNumeros(editCpf.getText().toString());
        String senha = editSenha.getText().toString();

        // Mostrar loading
        setLoginButtonLoading(true);

        // Realizar login via banco de dados
        LoginService.loginAsync(cpf, senha, new LoginService.LoginCallback() {
            @Override
            public void onSuccess(UsuarioDTO usuario) {
                runOnUiThread(() -> {
                    setLoginButtonLoading(false);
                    handleLoginSuccess(usuario);
                });
            }

            @Override
            public void onError(String mensagem) {
                runOnUiThread(() -> {
                    setLoginButtonLoading(false);
                    handleLoginError(mensagem);
                });
            }
        });
    }

    /**
     * Validação final de todos os campos usando Utils
     */
    private boolean validarTodosOsCampos() {
        // Utiliza a função de validação múltipla do Utils
        String primeiroErro = Utils.validarCampo(
                Utils.validarCpf(editCpf.getText().toString()),
                Utils.validarSenha(editSenha.getText().toString())
        );

        if (primeiroErro != null) {
            // Aplica os erros individualmente para exibição
            layoutCpf.setError(Utils.validarCpf(editCpf.getText().toString()));
            layoutSenha.setError(Utils.validarSenha(editSenha.getText().toString()));
            return false;
        }

        // Validação adicional específica para CPF
        String cpfNumeros = Utils.extrairNumeros(editCpf.getText().toString());
        if (cpfNumeros.length() != 11) {
            layoutCpf.setError("CPF deve ter 11 dígitos");
            return false;
        }

        return true;
    }

    /**
     * Define o estado de loading do botão de login
     */
    private void setLoginButtonLoading(boolean loading) {
        btnLogin.setEnabled(!loading);
        btnLogin.setText(loading ? "Entrando..." : "Entrar");
    }

    /**
     * Manipula o sucesso do login
     */
    private void handleLoginSuccess(UsuarioDTO usuario) {
        showToast("Bem-vindo, " + usuario.getNomeExibicao() + "!");

        // Limpar dados sensíveis do usuário
        usuario.clearSensitiveData();

        // Salvar CPF se checkbox estiver marcado
        if (checkboxLembrar.isChecked()) {
            saveCpfPreference(usuario.getCpf());
        } else {
            clearSavedCpf();
        }

        // Navegar para MainActivity passando dados do usuário
        Intent intent = new Intent(this, MainActivity.class);

        MyApp app = (MyApp) getApplicationContext();
        app.setUsuarioLogado(usuario); // Salva usuario na aplicação globalmente

        startActivity(intent);
        finish();
    }

    /**
     * Manipula erro no login
     */
    private void handleLoginError(String message) {
        showToast(message);

        // Limpar campos em caso de erro específicos
        if (message.contains("Senha")) {
            editSenha.setText("");
            editSenha.requestFocus();
        } else if (message.contains("CPF")) {
            editCpf.requestFocus();
        }

        // Se for erro de conexão, sugerir verificação
        if (message.contains("conexão") || message.contains("servidor")) {
            showToast("Verifique sua conexão com a internet");
        }
    }

    /**
     * Realizar login com Google
     */
    private void performGoogleLogin() {
        showToast("Login com Google em desenvolvimento");
        // TODO: Implementar Google Sign-In aqui
    }

    /**
     * Realizar login com Facebook
     */
    private void performFacebookLogin() {
        showToast("Login com Facebook em desenvolvimento");
        // TODO: Implementar Facebook Login aqui
    }

    /**
     * Manipula esqueci senha
     */
    private void handleForgotPassword() {
        Intent intent = new Intent(getBaseContext(), ForgotPasswordActivity.class);
        startActivity(intent);
        // Adiciona animação e transição suave
        overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);
    }

    /**
     * Trata o resultado da tela de recuperação de senha
     */
    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);

        if (requestCode == FORGOT_PASSWORD_REQUEST && resultCode == RESULT_OK) {
            // Senha foi redefinida com sucesso
            showToast("Senha redefinida com sucesso! Faça login com sua nova senha.");

            // Limpar o campo senha para que o usuário digite a nova
            editSenha.setText("");
            layoutSenha.setError(null);
            isSenhaValid = false;
            updateLoginButtonState();

            // Focar no campo senha
            editSenha.requestFocus();
        }
    }

    /**
     * Navega para tela de cadastro
     */
    private void navigateToRegister() {
        Intent intent = new Intent(this, RegisterActivity.class);
        startActivity(intent);
        // Não fazer finish() aqui para permitir voltar
    }

    /**
     * Carrega preferências salvas
     */
    private void loadSavedPreferences() {
        boolean rememberCpf = preferences.getBoolean(KEY_REMEMBER_CPF, false);
        checkboxLembrar.setChecked(rememberCpf);

        if (rememberCpf) {
            String savedCpf = preferences.getString(KEY_SAVED_CPF, "");
            if (!Utils.isCampoVazio(savedCpf)) {
                // O CpfMaskWatcher aplicará a máscara automaticamente
                editCpf.setText(savedCpf);

                // Focar no campo senha se CPF já estiver preenchido
                editSenha.requestFocus();
            }
        }
    }

    /**
     * Salva preferência de lembrar CPF
     */
    private void saveRememberPreference(boolean remember) {
        preferences.edit()
                .putBoolean(KEY_REMEMBER_CPF, remember)
                .apply();

        if (!remember) {
            clearSavedCpf();
        }
    }

    /**
     * Salva CPF nas preferências
     */
    private void saveCpfPreference(String cpf) {
        preferences.edit()
                .putString(KEY_SAVED_CPF, cpf)
                .apply();
    }

    /**
     * Limpa CPF salvo
     */
    private void clearSavedCpf() {
        preferences.edit()
                .remove(KEY_SAVED_CPF)
                .apply();
    }

    /**
     * Mostra toast
     */
    private void showToast(String message) {
        Toast.makeText(this, message, Toast.LENGTH_SHORT).show();
    }

    @Override
    protected void onResume() {
        super.onResume();
        // Revalidar campos quando voltar para a tela usando Utils
        String erroCpf = Utils.validarCpf(editCpf.getText().toString());
        layoutCpf.setError(erroCpf);
        String cpfNumeros = Utils.extrairNumeros(editCpf.getText().toString());
        isCpfValid = (erroCpf == null && cpfNumeros.length() == 11);

        String erroSenha = Utils.validarSenha(editSenha.getText().toString());
        layoutSenha.setError(erroSenha);
        isSenhaValid = (erroSenha == null);

        updateLoginButtonState();
    }
}