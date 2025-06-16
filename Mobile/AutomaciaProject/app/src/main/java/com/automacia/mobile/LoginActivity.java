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
        setupListeners();
        loadSavedPreferences();
    }

    private void setupWindowInsets() {
        ViewCompat.setOnApplyWindowInsetsListener(findViewById(R.id.main), (v, insets) -> {
            Insets systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars());
            v.setPadding(systemBars.left, systemBars.top, systemBars.right, systemBars.bottom);
            return insets;
        });

        View mainView = findViewById(R.id.main);
        Utils.applyGradientBackground(mainView);
    }

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

    private void setupListeners() {
        setupCpfValidation();
        setupSenhaValidation();
        setupClickListeners();
    }

    private void setupCpfValidation() {
        // Máscara de CPF
        editCpf.addTextChangedListener(new CpfMaskWatcher(editCpf));

        // Validação de CPF
        editCpf.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {}

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                validateCpf(s.toString());
                updateLoginButtonState();
            }

            @Override
            public void afterTextChanged(Editable s) {}
        });
    }

    private void setupSenhaValidation() {
        editSenha.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {}

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                validateSenha(s.toString());
                updateLoginButtonState();
            }

            @Override
            public void afterTextChanged(Editable s) {}
        });
    }

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

    private void validateCpf(String cpf) {
        // Remove formatação para validação
        String cleanCpf = cpf.replaceAll("[^0-9]", "");

        if (cleanCpf.length() == 0) {
            layoutCpf.setError(null);
            isCpfValid = false;
        } else if (cleanCpf.length() < 11) {
            layoutCpf.setError("CPF deve ter 11 dígitos");
            isCpfValid = false;
        } else if (cleanCpf.length() == 11) {
            if (Utils.isCpfValido(cleanCpf)) {
                layoutCpf.setError(null);
                isCpfValid = true;
            } else {
                layoutCpf.setError("CPF inválido");
                isCpfValid = false;
            }
        } else {
            layoutCpf.setError("CPF inválido");
            isCpfValid = false;
        }
    }

    private void validateSenha(String senha) {
        if (senha.length() == 0) {
            layoutSenha.setError(null);
            isSenhaValid = false;
        } else if (senha.length() < 6) {
            layoutSenha.setError("Senha deve ter pelo menos 6 caracteres");
            isSenhaValid = false;
        } else {
            layoutSenha.setError(null);
            isSenhaValid = true;
        }
    }

    private void updateLoginButtonState() {
        boolean isEnabled = isCpfValid && isSenhaValid;
        btnLogin.setEnabled(isEnabled);

        // Opcional: alterar aparência visual
        if (isEnabled) {
            btnLogin.setAlpha(1.0f);
        } else {
            btnLogin.setAlpha(0.6f);
        }
    }

    private void performLogin() {
        if (!isCpfValid || !isSenhaValid) {
            showToast("Por favor, corrija os erros antes de continuar");
            return;
        }

        String cpf = editCpf.getText().toString().replaceAll("[^0-9]", "");
        String senha = editSenha.getText().toString();

        // Mostrar loading (opcional)
        btnLogin.setEnabled(false);
        btnLogin.setText("Entrando...");

        // Simular chamada de API (substitua pela sua lógica real)
        simulateApiCall(cpf, senha);
    }

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

    private boolean isValidCredentials(String cpf, String senha) {
        // Implementar sua lógica de validação aqui
        // Por enquanto, aceita qualquer CPF válido com senha >= 6 chars
        return isCpfValid && senha.length() >= 6;
    }

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

    private void handleLoginError(String message) {
        showToast(message);

        // Limpar campos em caso de erro
        editSenha.setText("");
        editSenha.requestFocus();
    }

    private void performGoogleLogin() {
        showToast("Login com Google em desenvolvimento");
        // Implementar Google Sign-In aqui
    }

    private void performFacebookLogin() {
        showToast("Login com Facebook em desenvolvimento");
        // Implementar Facebook Login aqui
    }

    private void handleForgotPassword() {
        String cpf = editCpf.getText().toString().replaceAll("[^0-9]", "");

        if (cpf.isEmpty()) {
            showToast("Digite seu CPF para recuperar a senha");
            editCpf.requestFocus();
            return;
        }

        if (!isCpfValid) {
            showToast("Digite um CPF válido para recuperar a senha");
            return;
        }

        // Navegar para tela de recuperação ou mostrar dialog
        showToast("Instruções de recuperação enviadas para seu email");
        // Intent para ForgotPasswordActivity se existir
    }

    private void navigateToRegister() {
        Intent intent = new Intent(this, RegisterActivity.class);
        startActivity(intent);
        // Não fazer finish() aqui para permitir voltar
    }

    private void loadSavedPreferences() {
        boolean rememberCpf = preferences.getBoolean(KEY_REMEMBER_CPF, false);
        checkboxLembrar.setChecked(rememberCpf);

        if (rememberCpf) {
            String savedCpf = preferences.getString(KEY_SAVED_CPF, "");
            if (!savedCpf.isEmpty()) {
                editCpf.setText(savedCpf);
            }
        }
    }

    private void saveRememberPreference(boolean remember) {
        preferences.edit()
                .putBoolean(KEY_REMEMBER_CPF, remember)
                .apply();

        if (!remember) {
            clearSavedCpf();
        }
    }

    private void saveCpfPreference(String cpf) {
        preferences.edit()
                .putString(KEY_SAVED_CPF, cpf)
                .apply();
    }

    private void clearSavedCpf() {
        preferences.edit()
                .remove(KEY_SAVED_CPF)
                .apply();
    }

    private void showToast(String message) {
        Toast.makeText(this, message, Toast.LENGTH_SHORT).show();
    }

    @Override
    protected void onResume() {
        super.onResume();
        // Revalidar campos quando voltar para a tela
        validateCpf(editCpf.getText().toString());
        validateSenha(editSenha.getText().toString());
    }
}