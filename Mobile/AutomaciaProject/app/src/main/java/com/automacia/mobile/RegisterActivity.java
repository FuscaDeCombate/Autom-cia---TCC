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

import androidx.activity.EdgeToEdge;
import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;

import com.automacia.mobile.models.UsuarioDTO;
import com.automacia.mobile.services.RegisterService;
import com.automacia.mobile.utils.Utils;
import com.automacia.mobile.watchers.CpfMaskWatcher;
import com.automacia.mobile.watchers.TelefoneMaskWatcher;
import com.google.android.material.button.MaterialButton;
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

    // Views dos campos de entrada
    private TextInputLayout layoutNome, layoutCPF, layoutEmail, layoutTelefone, layoutSenha, layoutConSenha;
    private TextInputEditText editNomeC, editCPF, editEmail, editTelefone, editSenha, editConSenha;

    // Botões e controles
    private MaterialButton btnCadastrar, btnGoogle, btnFacebook;
    private View txtLogin;
    private ProgressBar progressBar;

    // Services
    private RegisterService registerService;

    // Flags de validação (somente validações locais)
    private boolean isNomeValido = false;
    private boolean isCpfValido = false;
    private boolean isEmailValido = false;
    private boolean isTelefoneValido = false;
    private boolean isSenhaValida = false;
    private boolean isConfirmacaoValida = false;

    // Controle do estado do cadastro
    private boolean isProcessandoCadastro = false;
    private boolean isAguardandoVerificacao = false;
    private UsuarioDTO usuarioTemporario = null;
    private AlertDialog dialogoVerificacao = null;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        EdgeToEdge.enable(this);
        setContentView(R.layout.activity_register);

        getWindow().setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_ADJUST_RESIZE);

        // Inicializa o service
        registerService = new RegisterService(getBaseContext());

        setupWindowInsets();
        setupGradientBackground();
        initializeViews();
        setupValidators();
        setupClickListeners();
    }

    private void setupWindowInsets() {
        ViewCompat.setOnApplyWindowInsetsListener(findViewById(R.id.main), (v, insets) -> {
            Insets systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars());
            v.setPadding(systemBars.left, systemBars.top, systemBars.right, systemBars.bottom);
            return insets;
        });
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
    }

    private void setupValidators() {
        setupNomeValidator();
        setupCpfValidator();
        setupEmailValidator();
        setupTelefoneValidator();
        setupSenhaValidator();
        setupConfirmacaoSenhaValidator();
    }

    private void setupNomeValidator() {
        editNomeC.addTextChangedListener(new TextWatcher() {
            @Override public void beforeTextChanged(CharSequence s, int start, int count, int after) {}
            @Override public void afterTextChanged(Editable s) {}

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                String erro = Utils.validarNome(s.toString());
                layoutNome.setError(erro);
                isNomeValido = (erro == null);
                updateButtonState();
            }
        });
    }

    private void setupCpfValidator() {
        // Aplica máscara de CPF
        editCPF.addTextChangedListener(new CpfMaskWatcher(editCPF));

        editCPF.addTextChangedListener(new TextWatcher() {
            @Override public void beforeTextChanged(CharSequence s, int start, int count, int after) {}
            @Override public void afterTextChanged(Editable s) {}

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                String cpfText = s.toString();
                String erro = Utils.validarCpf(cpfText);
                layoutCPF.setError(erro);

                String cpfNumeros = Utils.extrairNumeros(cpfText);
                // validação local: formato e tamanho
                isCpfValido = (erro == null && cpfNumeros.length() == 11);
                updateButtonState();
            }
        });
    }

    private void setupEmailValidator() {
        editEmail.addTextChangedListener(new TextWatcher() {
            @Override public void beforeTextChanged(CharSequence s, int start, int count, int after) {}
            @Override public void afterTextChanged(Editable s) {}

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                String emailText = s.toString().trim();
                String erro = Utils.validarEmail(emailText);
                layoutEmail.setError(erro);
                isEmailValido = (erro == null);
                updateButtonState();
            }
        });
    }

    private void setupTelefoneValidator() {
        editTelefone.addTextChangedListener(new TelefoneMaskWatcher(editTelefone));
        editTelefone.addTextChangedListener(new TextWatcher() {
            @Override public void beforeTextChanged(CharSequence s, int start, int count, int after) {}
            @Override public void afterTextChanged(Editable s) {}

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                String erro = Utils.validarTelefone(s.toString());
                layoutTelefone.setError(erro);

                String telefoneNumeros = Utils.extrairNumeros(s.toString());
                isTelefoneValido = (erro == null && telefoneNumeros.length() >= 10 && telefoneNumeros.length() <= 11);
                updateButtonState();
            }
        });
    }

    private void setupSenhaValidator() {
        editSenha.addTextChangedListener(new TextWatcher() {
            @Override public void beforeTextChanged(CharSequence s, int start, int count, int after) {}
            @Override public void afterTextChanged(Editable s) {}

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                String erro = Utils.validarSenha(s.toString());
                layoutSenha.setError(erro);
                isSenhaValida = (erro == null);

                if (!Utils.isCampoVazio(editConSenha.getText().toString())) {
                    validarConfirmacaoSenha();
                }

                updateButtonState();
            }
        });
    }

    private void setupConfirmacaoSenhaValidator() {
        editConSenha.addTextChangedListener(new TextWatcher() {
            @Override public void beforeTextChanged(CharSequence s, int start, int count, int after) {}
            @Override public void afterTextChanged(Editable s) {}

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                validarConfirmacaoSenha();
                updateButtonState();
            }
        });
    }

    private void validarConfirmacaoSenha() {
        String senha = editSenha.getText().toString();
        String confirmacao = editConSenha.getText().toString();

        String erro = Utils.validarConfirmacaoSenha(senha, confirmacao);
        layoutConSenha.setError(erro);
        isConfirmacaoValida = (erro == null);
    }

    private void updateButtonState() {
        boolean todosValidos = isNomeValido && isCpfValido && isEmailValido &&
                isTelefoneValido && isSenhaValida && isConfirmacaoValida;

        btnCadastrar.setEnabled(todosValidos && !isProcessandoCadastro && !isAguardandoVerificacao);
        btnCadastrar.setAlpha((todosValidos && !isProcessandoCadastro && !isAguardandoVerificacao) ? 1.0f : 0.5f);
    }

    private void setupClickListeners() {
        btnCadastrar.setOnClickListener(v -> realizarCadastro());

        txtLogin.setOnClickListener(v -> {
            if (isProcessandoCadastro || isAguardandoVerificacao) {
                Toast.makeText(this, "Aguarde o processamento do cadastro", Toast.LENGTH_SHORT).show();
                return;
            }

            Intent intent = new Intent(this, LoginActivity.class);
            startActivity(intent);
            finish();
        });

        btnGoogle.setOnClickListener(v -> {
            if (isProcessandoCadastro || isAguardandoVerificacao) {
                Toast.makeText(this, "Aguarde o processamento do cadastro", Toast.LENGTH_SHORT).show();
                return;
            }
            Toast.makeText(this, "Login com Google em desenvolvimento", Toast.LENGTH_SHORT).show();
        });

        btnFacebook.setOnClickListener(v -> {
            if (isProcessandoCadastro || isAguardandoVerificacao) {
                Toast.makeText(this, "Aguarde o processamento do cadastro", Toast.LENGTH_SHORT).show();
                return;
            }
            Toast.makeText(this, "Login com Facebook em desenvolvimento", Toast.LENGTH_SHORT).show();
        });
    }

    private void realizarCadastro() {
        if (!validarTodosOsCampos()) {
            return;
        }

        // Coleta os dados
        usuarioTemporario = coletarDadosUsuario();

        // Chama o service para registrar no Firebase
        registerService.registrarUsuario(usuarioTemporario, new RegisterService.RegisterCallback() {
            @Override
            public void onSuccess(String message) {
                // Cadastro inicial no Firebase foi bem-sucedido
                // Agora precisa aguardar verificação do email
                isAguardandoVerificacao = true;
                mostrarDialogoVerificacaoEmail(usuarioTemporario.getEmail());
            }

            @Override
            public void onError(String error) {
                Toast.makeText(RegisterActivity.this, error, Toast.LENGTH_LONG).show();
                resetarEstadoCadastro();
            }

            @Override
            public void onLoading(boolean isLoading) {
                isProcessandoCadastro = isLoading;
                updateButtonState();

                btnCadastrar.setText(isLoading ? "Criando conta..." : "Cadastrar");

                if (progressBar != null) {
                    progressBar.setVisibility(isLoading ? View.VISIBLE : View.GONE);
                }

                // Desabilita outros controles durante o processamento
                btnGoogle.setEnabled(!isLoading);
                btnFacebook.setEnabled(!isLoading);
                txtLogin.setEnabled(!isLoading);

                // Desabilita campos de entrada durante processamento
                setFieldsEnabled(!isLoading);
            }

            @Override
            public void onEmailVerificationSent(String email) {
                // Email de verificação foi enviado
                // Este callback será usado no diálogo de verificação
            }
        });
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
        if (dialogoVerificacao != null && dialogoVerificacao.isShowing()) {
            dialogoVerificacao.dismiss();
        }

        AlertDialog.Builder builder = new AlertDialog.Builder(this);
        builder.setTitle("Verifique seu email");
        builder.setMessage("Enviamos um link de confirmação para:\n" + email +
                "\n\nClique no link do email para ativar sua conta e depois toque em 'Verificar' para continuar.");
        builder.setCancelable(false);

        builder.setPositiveButton("Verificar", (dialog, which) -> {
            verificarEmailConfirmado();
        });

        builder.setNeutralButton("Reenviar Email", (dialog, which) -> {
            reenviarEmailVerificacao();
        });

        builder.setNegativeButton("Voltar", (dialog, which) -> {
            dialog.dismiss();
            resetarEstadoCadastro();
        });

        dialogoVerificacao = builder.create();
        dialogoVerificacao.show();
    }

    private void verificarEmailConfirmado() {
        // Mostra loading durante verificação
        if (progressBar != null) {
            progressBar.setVisibility(View.VISIBLE);
        }

        registerService.processarLinkVerificacao(new RegisterService.RegisterCallback() {
            @Override
            public void onSuccess(String message) {
                if (progressBar != null) {
                    progressBar.setVisibility(View.GONE);
                }

                // Email foi verificado, fecha o diálogo e completa o registro
                if (dialogoVerificacao != null && dialogoVerificacao.isShowing()) {
                    dialogoVerificacao.dismiss();
                }
                completarRegistroNoBanco();
            }

            @Override
            public void onError(String error) {
                if (progressBar != null) {
                    progressBar.setVisibility(View.GONE);
                }
                Toast.makeText(RegisterActivity.this,
                        "Email ainda não foi verificado. Clique no link do email e tente novamente.",
                        Toast.LENGTH_LONG).show();

                // Mostra o diálogo novamente após um pequeno delay
                new Handler(Looper.getMainLooper()).postDelayed(() -> {
                    mostrarDialogoVerificacaoEmail(usuarioTemporario.getEmail());
                }, 1000);
            }

            @Override
            public void onLoading(boolean isLoading) {
                // Não precisa de loading adicional aqui
            }

            @Override
            public void onEmailVerificationSent(String email) {
                // Não usado neste contexto
            }
        });
    }

    private void reenviarEmailVerificacao() {
        registerService.reenviarLinkVerificacao(new RegisterService.RegisterCallback() {
            @Override
            public void onSuccess(String message) {
                Toast.makeText(RegisterActivity.this, message, Toast.LENGTH_SHORT).show();
                // Mostra o diálogo novamente
                mostrarDialogoVerificacaoEmail(usuarioTemporario.getEmail());
            }

            @Override
            public void onError(String error) {
                Toast.makeText(RegisterActivity.this,
                        "Erro ao reenviar email: " + error,
                        Toast.LENGTH_LONG).show();
                // Mostra o diálogo novamente
                mostrarDialogoVerificacaoEmail(usuarioTemporario.getEmail());
            }

            @Override
            public void onLoading(boolean isLoading) {
                // Não precisa mostrar loading para reenvio
            }

            @Override
            public void onEmailVerificationSent(String email) {
                // Email reenviado
            }
        });
    }

    private void completarRegistroNoBanco() {
        if (progressBar != null) {
            progressBar.setVisibility(View.VISIBLE);
        }

        registerService.completarRegistroNoBanco(usuarioTemporario, new RegisterService.DatabaseCallback() {
            @Override
            public void onSuccess(String message) {
                Toast.makeText(RegisterActivity.this, message, Toast.LENGTH_LONG).show();

                // Redireciona para login
                Intent intent = new Intent(RegisterActivity.this, LoginActivity.class);
                intent.putExtra("email", usuarioTemporario.getEmail());
                intent.putExtra("cadastro_sucesso", true);
                intent.putExtra("message", "Cadastro finalizado com sucesso! Faça login para continuar.");

                startActivity(intent);
                finish();
            }

            @Override
            public void onError(String error) {
                Toast.makeText(RegisterActivity.this,
                        "Erro ao finalizar cadastro: " + error,
                        Toast.LENGTH_LONG).show();

                resetarEstadoCadastro();
            }

            @Override
            public void onLoading(boolean isLoading) {
                if (progressBar != null) {
                    progressBar.setVisibility(isLoading ? View.VISIBLE : View.GONE);
                }
            }
        });
    }

    private void resetarEstadoCadastro() {
        isProcessandoCadastro = false;
        isAguardandoVerificacao = false;
        usuarioTemporario = null;
        updateButtonState();
        setFieldsEnabled(true);
        btnCadastrar.setText("Cadastrar");

        if (progressBar != null) {
            progressBar.setVisibility(View.GONE);
        }

        // Reabilita outros controles
        btnGoogle.setEnabled(true);
        btnFacebook.setEnabled(true);
        txtLogin.setEnabled(true);
    }

    private UsuarioDTO coletarDadosUsuario() {
        UsuarioDTO usuario = new UsuarioDTO();
        usuario.setNome(editNomeC.getText().toString().trim());
        usuario.setCpf(Utils.extrairNumeros(editCPF.getText().toString()));
        usuario.setEmail(editEmail.getText().toString().trim().toLowerCase());
        usuario.setTelefone(Utils.extrairNumeros(editTelefone.getText().toString()));
        usuario.setSenha(editSenha.getText().toString());

        // Nome social é opcional - se não preenchido, fica vazio
        String nomeSocial = editNomeC.getText().toString().trim();
        usuario.setNomeSocial(nomeSocial.isEmpty() ? "" : nomeSocial);

        return usuario;
    }

    private boolean validarTodosOsCampos() {
        boolean todosValidos = true;

        String erroNome = Utils.validarNome(editNomeC.getText().toString());
        if (erroNome != null) {
            layoutNome.setError(erroNome);
            todosValidos = false;
        }

        String erroCpf = Utils.validarCpf(editCPF.getText().toString());
        String cpfNumeros = Utils.extrairNumeros(editCPF.getText().toString());
        if (erroCpf != null || cpfNumeros.length() != 11) {
            layoutCPF.setError(erroCpf != null ? erroCpf : "CPF deve ter 11 dígitos");
            todosValidos = false;
        }

        String erroEmail = Utils.validarEmail(editEmail.getText().toString());
        if (erroEmail != null) {
            layoutEmail.setError(erroEmail);
            todosValidos = false;
        }

        String erroTelefone = Utils.validarTelefone(editTelefone.getText().toString());
        String telefoneNumeros = Utils.extrairNumeros(editTelefone.getText().toString());
        if (erroTelefone != null || telefoneNumeros.length() < 10 || telefoneNumeros.length() > 11) {
            layoutTelefone.setError(erroTelefone != null ? erroTelefone : "Telefone deve ter entre 10 e 11 dígitos");
            todosValidos = false;
        }

        String erroSenha = Utils.validarSenha(editSenha.getText().toString());
        if (erroSenha != null) {
            layoutSenha.setError(erroSenha);
            todosValidos = false;
        }

        String erroConfirmacao = Utils.validarConfirmacaoSenha(
                editSenha.getText().toString(),
                editConSenha.getText().toString()
        );
        if (erroConfirmacao != null) {
            layoutConSenha.setError(erroConfirmacao);
            todosValidos = false;
        }

        return todosValidos;
    }

    @Override
    protected void onResume() {
        super.onResume();

        // Atualiza estado dos botões
        if (btnCadastrar != null && !isProcessandoCadastro && !isAguardandoVerificacao) {
            updateButtonState();
            btnCadastrar.setText("Cadastrar");
        }

        // Detecção automática: se estava aguardando verificação e tem usuário temporário,
        // verifica se o email foi confirmado (útil quando usuário verifica em outro device)
        if (isAguardandoVerificacao && usuarioTemporario != null) {
            // Pequeno delay para evitar múltiplas verificações
            new Handler(Looper.getMainLooper()).postDelayed(() -> {
                verificarEmailConfirmadoSilencioso();
            }, 500);
        }
    }

    /**
     * Verifica email confirmado de forma silenciosa (sem mostrar diálogos)
     * Usado no onResume para detectar verificação feita em outro device
     */
    private void verificarEmailConfirmadoSilencioso() {
        registerService.processarLinkVerificacao(new RegisterService.RegisterCallback() {
            @Override
            public void onSuccess(String message) {
                // Email foi verificado! Fecha qualquer diálogo aberto e completa o registro
                if (dialogoVerificacao != null && dialogoVerificacao.isShowing()) {
                    dialogoVerificacao.dismiss();
                }

                Toast.makeText(RegisterActivity.this,
                        "Email verificado! Finalizando cadastro...",
                        Toast.LENGTH_SHORT).show();

                completarRegistroNoBanco();
            }

            @Override
            public void onError(String error) {
                // Ignora erros na verificação silenciosa
                // O usuário ainda pode usar o botão "Verificar" manualmente
            }

            @Override
            public void onLoading(boolean isLoading) {
                // Não mostra loading na verificação silenciosa
            }

            @Override
            public void onEmailVerificationSent(String email) {
                // Não usado neste contexto
            }
        });
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();

        // Fecha diálogo se estiver aberto
        if (dialogoVerificacao != null && dialogoVerificacao.isShowing()) {
            dialogoVerificacao.dismiss();
        }

        // Limpa o service
        if (registerService != null) {
            registerService.shutdown();
        }
    }

    @Override
    public void onBackPressed() {
        if (isProcessandoCadastro || isAguardandoVerificacao) {
            Toast.makeText(this, "Aguarde o cadastro ser processado", Toast.LENGTH_SHORT).show();
            return;
        }
        super.onBackPressed();
    }
}