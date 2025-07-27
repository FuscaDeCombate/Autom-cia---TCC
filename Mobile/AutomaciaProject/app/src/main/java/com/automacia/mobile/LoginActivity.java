package com.automacia.mobile;

import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.text.Editable;
import android.text.TextWatcher;
import android.util.Patterns;
import android.view.View;
import android.widget.TextView;
import android.widget.Toast;

import androidx.activity.EdgeToEdge;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;

import com.google.android.material.button.MaterialButton;
import com.google.android.material.checkbox.MaterialCheckBox;
import com.google.android.material.textfield.TextInputEditText;
import com.google.android.material.textfield.TextInputLayout;

/**
 * Activity responsável pelo login de usuários
 * Implementa validações em tempo real usando Utils e formatação automática
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
     * Realiza o login do usuário
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
        btnLogin.setEnabled(false);
        btnLogin.setText("Entrando...");

        // Simular chamada de API (substitua pela sua lógica real)
        simulateApiCall(cpf, senha);
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
     * Simula chamada de API
     */
    private void simulateApiCall(String cpf, String senha) {
        // Simular delay de rede
        new android.os.Handler().postDelayed(() -> {
            // Resetar botão
            btnLogin.setEnabled(true);
            btnLogin.setText("Entrar");

            // Simular sucesso (substitua pela sua lógica real)
            if (isValidCredentials(cpf, senha)) {
                handleLoginSuccess(cpf);
            } else {
                handleLoginError("CPF ou senha incorretos");
            }
        }, 1500);
    }

    /**
     * Verifica se as credenciais são válidas
     */
    private boolean isValidCredentials(String cpf, String senha) {
        // Implementar sua lógica de validação aqui
        // Por enquanto, aceita qualquer CPF válido com senha >= 6 chars
        return Utils.isCpfValido(cpf) && senha.length() >= 6;
    }

    /**
     * Manipula o sucesso do login
     */
    private void handleLoginSuccess(String cpf) {
        showToast("Login realizado com sucesso!");

        // Salvar CPF se checkbox estiver marcado
        if (checkboxLembrar.isChecked()) {
            saveCpfPreference(cpf);
        } else {
            clearSavedCpf();
        }

        // Navegar para MainActivity
        Intent intent = new Intent(this, MainActivity.class);
        intent.putExtra("user_cpf", cpf);
        startActivity(intent);
        finish();
    }

    /**
     * Manipula erro no login
     */
    private void handleLoginError(String message) {
        showToast(message);

        // Limpar campos em caso de erro
        editSenha.setText("");
        editSenha.requestFocus();
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
        String cpfFormatado = editCpf.getText().toString();
        String cpfNumeros = Utils.extrairNumeros(cpfFormatado);

        if (Utils.isCampoVazio(cpfFormatado)) {
            showToast("Digite seu CPF para recuperar a senha");
            editCpf.requestFocus();
            return;
        }

        String erroCpf = Utils.validarCpf(cpfFormatado);
        if (erroCpf != null) {
            showToast("Digite um CPF válido para recuperar a senha");
            return;
        }

        // TODO: Implementar recuperação de senha
        showToast("Instruções enviadas para o email cadastrado");
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
                editCpf.setText(savedCpf);
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