package com.automacia.mobile;

import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.text.Editable;
import android.text.TextWatcher;
import android.view.View;
import android.view.WindowManager;
import android.widget.ProgressBar;
import android.widget.Toast;

import androidx.appcompat.app.AppCompatActivity;
import androidx.core.content.ContextCompat;
import androidx.lifecycle.ViewModelProvider;

import com.automacia.mobile.dialogs.EmailVerificationDialog;
import com.automacia.mobile.utils.Utils;
import com.automacia.mobile.viewmodels.RegisterViewModel;
import com.automacia.mobile.watchers.CpfMaskWatcher;
import com.automacia.mobile.watchers.TelefoneMaskWatcher;
import com.google.android.material.button.MaterialButton;
import com.google.android.material.floatingactionbutton.FloatingActionButton;
import com.google.android.material.textfield.TextInputEditText;
import com.google.android.material.textfield.TextInputLayout;

/**
 * Activity responsável pelo cadastro de novos usuários
 * Implementa validações em tempo real, formatação automática e integração com Firebase Auth
 *
 * Fluxo do cadastro:
 * 1. Validação local dos campos
 * 2. Criação da conta no Firebase + envio de email de verificação
 * 3. Usuário confirma email (automaticamente detectado no onResume)
 * 4. Finalização do cadastro no banco local
 */
public class RegisterActivity extends AppCompatActivity {

    private FloatingActionButton fabDebugFill;

    // ViewModel
    private RegisterViewModel viewModel;

    // Views dos campos de entrada
    private TextInputLayout layoutNome, layoutCPF, layoutEmail, layoutTelefone, layoutSenha, layoutConSenha;
    private TextInputEditText editNomeC, editCPF, editEmail, editTelefone, editSenha, editConSenha;

    // Botões e controles
    private MaterialButton btnCadastrar, btnGoogle, btnFacebook;
    private View txtLogin;
    private ProgressBar progressBar;

    // Diálogo de verificação
    private EmailVerificationDialog emailVerificationDialog = null;
    private final Handler verificationHandler = new Handler(Looper.getMainLooper());

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_register);

        getWindow().setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_ADJUST_RESIZE);
        getWindow().setStatusBarColor(ContextCompat.getColor(this, R.color.primary));

        // Inicializa o ViewModel
        viewModel = new ViewModelProvider(this).get(RegisterViewModel.class);

        setupGradientBackground();
        initializeViews();
        setupValidators();
        setupClickListeners();
        observerViewModel();
    }

    private void setupGradientBackground() {
        View mainView = findViewById(R.id.main);
        Utils.applyGradientBackground(mainView);
    }

    private void initializeViews() {
        layoutNome = findViewById(R.id.layoutNome);
        layoutCPF = findViewById(R.id.layoutCPF);
        layoutEmail = findViewById(R.id.layoutEmail);
        layoutTelefone = findViewById(R.id.layoutTelefone);
        layoutSenha = findViewById(R.id.layoutSenha);
        layoutConSenha = findViewById(R.id.layoutConSenha);

        editNomeC = findViewById(R.id.editNomeC);
        editCPF = findViewById(R.id.editCPF);
        editEmail = findViewById(R.id.editEmail);
        editTelefone = findViewById(R.id.editTelefone);
        editSenha = findViewById(R.id.editSenha);
        editConSenha = findViewById(R.id.editConSenha);

        btnCadastrar = findViewById(R.id.btnRegistrar);
        btnGoogle = findViewById(R.id.btnGoogle);
        btnFacebook = findViewById(R.id.btnFacebook);
        txtLogin = findViewById(R.id.txtLogin);

        progressBar = findViewById(R.id.progressBar);
        if (progressBar != null) {
            progressBar.setVisibility(View.GONE);
        }

        fabDebugFill = findViewById(R.id.fabDebugFill);
    }

    private void setupValidators() {
        // Nome
        editNomeC.addTextChangedListener(new TextWatcher() {
            @Override public void beforeTextChanged(CharSequence s, int start, int count, int after) {}
            @Override public void afterTextChanged(Editable s) {}
            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                viewModel.validarNome(s.toString());
            }
        });

        // CPF
        editCPF.addTextChangedListener(new CpfMaskWatcher(editCPF));
        editCPF.addTextChangedListener(new TextWatcher() {
            @Override public void beforeTextChanged(CharSequence s, int start, int count, int after) {}
            @Override public void afterTextChanged(Editable s) {}
            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                viewModel.validarCpf(s.toString());
            }
        });

        // Email
        editEmail.addTextChangedListener(new TextWatcher() {
            @Override public void beforeTextChanged(CharSequence s, int start, int count, int after) {}
            @Override public void afterTextChanged(Editable s) {}
            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                viewModel.validarEmail(s.toString());
            }
        });

        // Telefone
        editTelefone.addTextChangedListener(new TelefoneMaskWatcher(editTelefone));
        editTelefone.addTextChangedListener(new TextWatcher() {
            @Override public void beforeTextChanged(CharSequence s, int start, int count, int after) {}
            @Override public void afterTextChanged(Editable s) {}
            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                viewModel.validarTelefone(s.toString());
            }
        });

        // Senha
        editSenha.addTextChangedListener(new TextWatcher() {
            @Override public void beforeTextChanged(CharSequence s, int start, int count, int after) {}
            @Override public void afterTextChanged(Editable s) {}
            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                viewModel.validarSenha(s.toString());

                // Revalida confirmação se já foi preenchida
                if (editConSenha.getText() != null && !Utils.isCampoVazio(editConSenha.getText().toString())) {
                    viewModel.validarConfirmacao(editConSenha.getText().toString());
                }
            }
        });

        // Confirmação senha
        editConSenha.addTextChangedListener(new TextWatcher() {
            @Override public void beforeTextChanged(CharSequence s, int start, int count, int after) {}
            @Override public void afterTextChanged(Editable s) {}
            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                viewModel.validarConfirmacao(s.toString());
            }
        });
    }

    private void setupClickListeners() {
        btnCadastrar.setOnClickListener(v -> realizarCadastro());

        txtLogin.setOnClickListener(v -> {
            if (viewModel.isProcessandoCadastro()) {
                Toast.makeText(this, "Aguarde o processamento do cadastro", Toast.LENGTH_SHORT).show();
                return;
            }

            Intent intent = new Intent(this, LoginActivity.class);
            startActivity(intent);
            finish();
        });

        btnGoogle.setOnClickListener(v -> {
            if (viewModel.isProcessandoCadastro()) {
                Toast.makeText(this, "Aguarde o processamento do cadastro", Toast.LENGTH_SHORT).show();
                return;
            }
            Toast.makeText(this, "Login com Google em desenvolvimento", Toast.LENGTH_SHORT).show();
        });

        btnFacebook.setOnClickListener(v -> {
            if (viewModel.isProcessandoCadastro()) {
                Toast.makeText(this, "Aguarde o processamento do cadastro", Toast.LENGTH_SHORT).show();
                return;
            }
            Toast.makeText(this, "Login com Facebook em desenvolvimento", Toast.LENGTH_SHORT).show();
        });

        fabDebugFill.setOnClickListener(v -> preencherCamposDebug());
    }

    private void observerViewModel() {
        // Observa erros de validação
        viewModel.getNomeError().observe(this, erro -> layoutNome.setError(erro));
        viewModel.getCpfError().observe(this, erro -> layoutCPF.setError(erro));
        viewModel.getEmailError().observe(this, erro -> layoutEmail.setError(erro));
        viewModel.getTelefoneError().observe(this, erro -> layoutTelefone.setError(erro));
        viewModel.getSenhaError().observe(this, erro -> layoutSenha.setError(erro));
        viewModel.getConfirmacaoError().observe(this, erro -> layoutConSenha.setError(erro));

        // Observa estado do formulário
        viewModel.getIsFormValid().observe(this, isValid -> {
            btnCadastrar.setEnabled(isValid);
            btnCadastrar.setAlpha(isValid ? 1.0f : 0.5f);
        });

        // Observa loading
        viewModel.getIsLoading().observe(this, isLoading -> {
            if (progressBar != null) {
                progressBar.setVisibility(isLoading ? View.VISIBLE : View.GONE);
            }

            btnCadastrar.setText(isLoading ? "Criando conta..." : "Cadastrar");

            // Desabilita outros controles
            btnGoogle.setEnabled(!isLoading);
            btnFacebook.setEnabled(!isLoading);
            txtLogin.setEnabled(!isLoading);
            setFieldsEnabled(!isLoading);
        });

        // Observa eventos de erro
        viewModel.getErrorEvent().observe(this, error -> {
            if (error != null) {
                Toast.makeText(this, error, Toast.LENGTH_LONG).show();
            }
        });

        // Observa eventos de sucesso
        viewModel.getSuccessEvent().observe(this, message -> {
            if (message != null) {
                Toast.makeText(this, message, Toast.LENGTH_SHORT).show();
            }
        });

        // Observa quando deve mostrar diálogo de verificação
        viewModel.getMostrarDialogoVerificacao().observe(this, mostrar -> {
            if (mostrar != null && mostrar) {
                String email = viewModel.getEmailParaVerificacao().getValue();
                if (email != null) {
                    mostrarDialogoVerificacaoEmail(email);
                }
            }
        });

        // Observa quando deve navegar para login
        viewModel.getNavegarParaLogin().observe(this, navegar -> {
            if (navegar != null && navegar) {
                navegarParaLogin();
            }
        });
    }

    private void realizarCadastro() {
        String nome = editNomeC.getText() != null ? editNomeC.getText().toString() : "";
        String cpf = editCPF.getText() != null ? editCPF.getText().toString() : "";
        String email = editEmail.getText() != null ? editEmail.getText().toString() : "";
        String telefone = editTelefone.getText() != null ? editTelefone.getText().toString() : "";
        String senha = editSenha.getText() != null ? editSenha.getText().toString() : "";

        viewModel.realizarCadastro(nome, cpf, email, telefone, senha);
    }

    private void setFieldsEnabled(boolean enabled) {
        editNomeC.setEnabled(enabled);
        editCPF.setEnabled(enabled);
        editEmail.setEnabled(enabled);
        editTelefone.setEnabled(enabled);
        editSenha.setEnabled(enabled);
        editConSenha.setEnabled(enabled);
    }

    private void mostrarDialogoVerificacaoEmail(String email) {
        // Fecha diálogo anterior se existir
        if (emailVerificationDialog != null && emailVerificationDialog.isShowing()) {
            emailVerificationDialog.dismiss();
        }

        emailVerificationDialog = new EmailVerificationDialog(
                this,
                email,
                new EmailVerificationDialog.EmailVerificationListener() {
                    @Override
                    public void onVerifyClick() {
                        viewModel.verificarEmailConfirmado();
                    }

                    @Override
                    public void onResendClick() {
                        viewModel.reenviarEmailVerificacao();
                        if (emailVerificationDialog != null && emailVerificationDialog.isShowing()) {
                            emailVerificationDialog.resetResendTimer();
                        }
                    }

                    @Override
                    public void onBackClick() {
                        viewModel.resetarEstadoCadastro();
                        if (emailVerificationDialog != null && emailVerificationDialog.isShowing()) {
                            emailVerificationDialog.dismiss();
                        }
                    }
                }
        );

        emailVerificationDialog.show();
    }

    private void navegarParaLogin() {
        if (emailVerificationDialog != null && emailVerificationDialog.isShowing()) {
            emailVerificationDialog.dismiss();
        }

        String email = viewModel.getEmailParaVerificacao().getValue();
        Intent intent = new Intent(RegisterActivity.this, LoginActivity.class);
        if (email != null) {
            intent.putExtra("email", email);
        }
        intent.putExtra("cadastro_sucesso", true);
        intent.putExtra("message", "Cadastro finalizado com sucesso! Faça login para continuar.");

        startActivity(intent);
        finish();
    }

    private void preencherCamposDebug() {
        editNomeC.setText("João da Silva Santos");
        editCPF.setText("24436263851");
        editEmail.setText("piguimdebarbicha@gmail.com");
        editTelefone.setText("11987654321");
        editSenha.setText("Senha@123");
        editConSenha.setText("Senha@123");
    }

    @Override
    protected void onResume() {
        super.onResume();

        // Verifica email confirmado silenciosamente se estava aguardando
        Boolean aguardando = viewModel.getIsAguardandoVerificacao().getValue();
        if (aguardando != null && aguardando) {
            verificationHandler.postDelayed(() -> {
                viewModel.verificarEmailConfirmadoSilencioso();
            }, 500);
        }
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();

        verificationHandler.removeCallbacksAndMessages(null);

        if (emailVerificationDialog != null && emailVerificationDialog.isShowing()) {
            emailVerificationDialog.dismiss();
        }
    }

    @Override
    public void onBackPressed() {
        if (viewModel.isProcessandoCadastro()) {
            Toast.makeText(this, "Aguarde o cadastro ser processado", Toast.LENGTH_SHORT).show();
            return;
        }
        super.onBackPressed();
    }
}