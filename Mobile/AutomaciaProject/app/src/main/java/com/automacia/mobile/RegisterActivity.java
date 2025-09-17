package com.automacia.mobile;

import android.content.Intent;
import android.os.Bundle;
import android.text.Editable;
import android.text.TextWatcher;
import android.view.View;
import android.widget.ProgressBar;
import android.widget.Toast;

import androidx.activity.EdgeToEdge;
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
 * Implementa validações em tempo real, formatação automática e integração com banco de dados
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

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        EdgeToEdge.enable(this);
        setContentView(R.layout.activity_register);

        // Inicializa o service
        registerService = new RegisterService();

        setupWindowInsets();
        setupGradientBackground();
        initializeViews();
        setupValidators();
        setupClickListeners();

        // Testa conexão inicial
        testarConexaoInicial();
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

    private void testarConexaoInicial() {
        registerService.testarConexao(new RegisterService.CheckExistenceCallback() {
            @Override
            public void onResult(boolean ok, String field) {
                // Conexão OK
            }

            @Override
            public void onError(String error) {
                Toast.makeText(RegisterActivity.this,
                        "Problema de conexão: " + error,
                        Toast.LENGTH_LONG).show();
            }
        });
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

        btnCadastrar.setEnabled(todosValidos);
        btnCadastrar.setAlpha(todosValidos ? 1.0f : 0.5f);
    }

    private void setupClickListeners() {
        btnCadastrar.setOnClickListener(v -> realizarCadastro());

        txtLogin.setOnClickListener(v -> {
            Intent intent = new Intent(this, LoginActivity.class);
            startActivity(intent);
            finish();
        });

        btnGoogle.setOnClickListener(v -> {
            Toast.makeText(this, "Login com Google em desenvolvimento", Toast.LENGTH_SHORT).show();
        });

        btnFacebook.setOnClickListener(v -> {
            Toast.makeText(this, "Login com Facebook em desenvolvimento", Toast.LENGTH_SHORT).show();
        });
    }

    private void realizarCadastro() {
        if (!validarTodosOsCampos()) {
            return;
        }

        // Coleta os dados
        UsuarioDTO usuario = coletarDadosUsuario();

        // Chama o service para registrar
        registerService.registrarUsuario(usuario, new RegisterService.RegisterCallback() {
            @Override
            public void onSuccess(String message) {
                Toast.makeText(RegisterActivity.this, message, Toast.LENGTH_LONG).show();

                // Redireciona para login com email preenchido
                Intent intent = new Intent(RegisterActivity.this, LoginActivity.class);
                intent.putExtra("email", usuario.getEmail());
                intent.putExtra("cadastro_sucesso", true);
                startActivity(intent);
                finish();
            }

            @Override
            public void onError(String error) {
                Toast.makeText(RegisterActivity.this, error, Toast.LENGTH_LONG).show();
            }

            @Override
            public void onLoading(boolean isLoading) {
                btnCadastrar.setEnabled(!isLoading);
                btnCadastrar.setText(isLoading ? "Cadastrando..." : "Cadastrar");

                if (progressBar != null) {
                    progressBar.setVisibility(isLoading ? View.VISIBLE : View.GONE);
                }

                btnGoogle.setEnabled(!isLoading);
                btnFacebook.setEnabled(!isLoading);
                txtLogin.setEnabled(!isLoading);
            }
        });
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
        if (btnCadastrar != null) {
            updateButtonState();
            btnCadastrar.setText("Cadastrar");
        }
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        if (registerService != null) {
            registerService.shutdown();
        }
    }

    @Override
    public void onBackPressed() {
        if (btnCadastrar != null && !btnCadastrar.isEnabled()) {
            Toast.makeText(this, "Aguarde o cadastro ser processado", Toast.LENGTH_SHORT).show();
            return;
        }
        super.onBackPressed();
    }
}
