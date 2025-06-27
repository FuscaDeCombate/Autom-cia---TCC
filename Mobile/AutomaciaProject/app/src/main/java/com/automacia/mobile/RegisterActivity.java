package com.automacia.mobile;

import android.content.Intent;
import android.os.Bundle;
import android.text.Editable;
import android.text.TextWatcher;
import android.util.Patterns;
import android.view.View;
import android.widget.Toast;

import androidx.activity.EdgeToEdge;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;

import com.google.android.material.button.MaterialButton;
import com.google.android.material.textfield.TextInputEditText;
import com.google.android.material.textfield.TextInputLayout;

/**
 * Activity responsável pelo cadastro de novos usuários
 * Implementa validações em tempo real e formatação automática
 */
public class RegisterActivity extends AppCompatActivity {

    // Views dos campos de entrada
    private TextInputLayout layoutNome, layoutCPF, layoutEmail, layoutTelefone, layoutSenha, layoutConSenha;
    private TextInputEditText editNomeC, editCPF, editEmail, editTelefone, editSenha, editConSenha;

    // Botões e controles
    private MaterialButton btnCadastrar, btnGoogle, btnFacebook;
    private View txtLogin;

    // Flags de validação
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

        setupWindowInsets();
        setupGradientBackground();
        initializeViews();
        setupValidators();
        setupClickListeners();
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
    }

    /**
     * Aplica o gradiente de fundo
     */
    private void setupGradientBackground() {
        View mainView = findViewById(R.id.main);
        Utils.applyGradientBackground(mainView);
    }

    /**
     * Inicializa todas as views
     */
    private void initializeViews() {
        // TextInputLayouts
        layoutNome = findViewById(R.id.layoutNome);
        layoutCPF = findViewById(R.id.layoutCPF);
        layoutEmail = findViewById(R.id.layoutEmail);
        layoutTelefone = findViewById(R.id.layoutTelefone);
        layoutSenha = findViewById(R.id.layoutSenha);
        layoutConSenha = findViewById(R.id.layoutConSenha);

        // EditTexts
        editNomeC = findViewById(R.id.editNomeC);
        editCPF = findViewById(R.id.editCPF);
        editEmail = findViewById(R.id.editEmail);
        editTelefone = findViewById(R.id.editTelefone);
        editSenha = findViewById(R.id.editSenha);
        editConSenha = findViewById(R.id.editConSenha);

        // Botões
        btnCadastrar = findViewById(R.id.btnRegistrar);
        btnGoogle = findViewById(R.id.btnGoogle);
        btnFacebook = findViewById(R.id.btnFacebook);
        txtLogin = findViewById(R.id.txtLogin);
    }

    /**
     * Configura os validadores em tempo real para todos os campos
     */
    private void setupValidators() {
        setupNomeValidator();
        setupCpfValidator();
        setupEmailValidator();
        setupTelefoneValidator();
        setupSenhaValidator();
        setupConfirmacaoSenhaValidator();
    }

    /**
     * Validador para o campo Nome
     */
    private void setupNomeValidator() {
        editNomeC.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {}

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                String nome = s.toString().trim();

                if (nome.isEmpty()) {
                    layoutNome.setError("Nome é obrigatório");
                    isNomeValido = false;
                } else if (nome.length() < 2) {
                    layoutNome.setError("Nome muito curto");
                    isNomeValido = false;
                } else if (!nome.matches("^[a-zA-ZÀ-ÿ\\s]+$")) {
                    layoutNome.setError("Nome deve conter apenas letras");
                    isNomeValido = false;
                } else {
                    layoutNome.setError(null);
                    isNomeValido = true;
                }
                updateButtonState();
            }

            @Override
            public void afterTextChanged(Editable s) {}
        });
    }

    /**
     * Validador para o campo CPF com máscara e validação
     */
    private void setupCpfValidator() {
        // Aplica máscara de CPF
        editCPF.addTextChangedListener(new CpfMaskWatcher(editCPF));

        // Validação do CPF
        editCPF.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {}

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                String cpfFormatado = s.toString();
                String cpfNumeros = cpfFormatado.replaceAll("[^\\d]", "");

                if (cpfNumeros.isEmpty()) {
                    layoutCPF.setError("CPF é obrigatório");
                    isCpfValido = false;
                } else if (cpfNumeros.length() < 11) {
                    layoutCPF.setError(null); // Não mostra erro enquanto digita
                    isCpfValido = false;
                } else if (cpfNumeros.length() == 11) {
                    if (Utils.isCpfValido(cpfNumeros)) {
                        layoutCPF.setError(null);
                        isCpfValido = true;
                    } else {
                        layoutCPF.setError("CPF inválido");
                        isCpfValido = false;
                    }
                } else {
                    layoutCPF.setError("CPF inválido");
                    isCpfValido = false;
                }
                updateButtonState();
            }

            @Override
            public void afterTextChanged(Editable s) {}
        });
    }

    /**
     * Validador para o campo Email
     */
    private void setupEmailValidator() {
        editEmail.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {}

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                String email = s.toString().trim();

                if (email.isEmpty()) {
                    layoutEmail.setError("E-mail é obrigatório");
                    isEmailValido = false;
                } else if (!Patterns.EMAIL_ADDRESS.matcher(email).matches()) {
                    layoutEmail.setError("E-mail inválido");
                    isEmailValido = false;
                } else {
                    layoutEmail.setError(null);
                    isEmailValido = true;
                }
                updateButtonState();
            }

            @Override
            public void afterTextChanged(Editable s) {}
        });
    }

    /**
     * Validador para o campo Telefone com máscara
     */
    private void setupTelefoneValidator() {
        // Aplica máscara de telefone
        editTelefone.addTextChangedListener(new TelefoneMaskWatcher(editTelefone));

        editTelefone.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {}

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                String telefone = s.toString().replaceAll("[^\\d]", "");

                if (telefone.isEmpty()) {
                    layoutTelefone.setError("Telefone é obrigatório");
                    isTelefoneValido = false;
                } else if (telefone.length() < 10) {
                    layoutTelefone.setError(null); // Não mostra erro enquanto digita
                    isTelefoneValido = false;
                } else if (telefone.length() >= 10 && telefone.length() <= 11) {
                    layoutTelefone.setError(null);
                    isTelefoneValido = true;
                } else {
                    layoutTelefone.setError("Telefone inválido");
                    isTelefoneValido = false;
                }
                updateButtonState();
            }

            @Override
            public void afterTextChanged(Editable s) {}
        });
    }

    /**
     * Validador para o campo Senha
     */
    private void setupSenhaValidator() {
        editSenha.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {}

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                String senha = s.toString();

                if (senha.isEmpty()) {
                    layoutSenha.setError("Senha é obrigatória");
                    isSenhaValida = false;
                } else if (senha.length() < 6) {
                    layoutSenha.setError("Senha deve ter pelo menos 6 caracteres");
                    isSenhaValida = false;
                } else if (!senha.matches(".*[a-zA-Z].*")) {
                    layoutSenha.setError("Senha deve conter pelo menos uma letra");
                    isSenhaValida = false;
                } else {
                    layoutSenha.setError(null);
                    isSenhaValida = true;
                }

                // Revalida confirmação de senha
                if (!editConSenha.getText().toString().isEmpty()) {
                    validarConfirmacaoSenha();
                }

                updateButtonState();
            }

            @Override
            public void afterTextChanged(Editable s) {}
        });
    }

    /**
     * Validador para o campo Confirmação de Senha
     */
    private void setupConfirmacaoSenhaValidator() {
        editConSenha.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {}

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                validarConfirmacaoSenha();
                updateButtonState();
            }

            @Override
            public void afterTextChanged(Editable s) {}
        });
    }

    /**
     * Valida se a confirmação da senha está correta
     */
    private void validarConfirmacaoSenha() {
        String senha = editSenha.getText().toString();
        String confirmacao = editConSenha.getText().toString();

        if (confirmacao.isEmpty()) {
            layoutConSenha.setError("Confirmação de senha é obrigatória");
            isConfirmacaoValida = false;
        } else if (!senha.equals(confirmacao)) {
            layoutConSenha.setError("As senhas não coincidem");
            isConfirmacaoValida = false;
        } else {
            layoutConSenha.setError(null);
            isConfirmacaoValida = true;
        }
    }

    /**
     * Atualiza o estado do botão baseado nas validações
     */
    private void updateButtonState() {
        boolean todosValidos = isNomeValido && isCpfValido && isEmailValido &&
                isTelefoneValido && isSenhaValida && isConfirmacaoValida;

        btnCadastrar.setEnabled(todosValidos);
        btnCadastrar.setAlpha(todosValidos ? 1.0f : 0.5f);
    }

    /**
     * Configura os listeners dos botões
     */
    private void setupClickListeners() {
        btnCadastrar.setOnClickListener(v -> realizarCadastro());

        txtLogin.setOnClickListener(v -> {
            Intent intent = new Intent(this, LoginActivity.class);
            startActivity(intent);
            finish();
        });

        btnGoogle.setOnClickListener(v -> {
            Toast.makeText(this, "Login com Google em desenvolvimento", Toast.LENGTH_SHORT).show();
            // TODO: Implementar login com Google
        });

        btnFacebook.setOnClickListener(v -> {
            Toast.makeText(this, "Login com Facebook em desenvolvimento", Toast.LENGTH_SHORT).show();
            // TODO: Implementar login com Facebook
        });
    }

    /**
     * Realiza o cadastro do usuário
     */
    private void realizarCadastro() {
        if (!validarTodosOsCampos()) {
            return;
        }

        // Desabilita o botão para evitar cliques duplos
        btnCadastrar.setEnabled(false);
        btnCadastrar.setText("Cadastrando...");

        // Coleta os dados
        UsuarioDTO usuario = coletarDadosUsuario();

        // TODO: Implementar chamada para API/Banco de dados
        // Por enquanto, simula sucesso
        simularCadastro(usuario);
    }

    /**
     * Coleta todos os dados do formulário
     */
    private UsuarioDTO coletarDadosUsuario() {
        UsuarioDTO usuario = new UsuarioDTO();
        usuario.setNome(editNomeC.getText().toString().trim());
        usuario.setCpf(editCPF.getText().toString().replaceAll("[^\\d]", ""));
        usuario.setEmail(editEmail.getText().toString().trim().toLowerCase());
        usuario.setTelefone(editTelefone.getText().toString().replaceAll("[^\\d]", ""));
        usuario.setSenha(editSenha.getText().toString());
        return usuario;
    }

    /**
     * Simula o processo de cadastro
     */
    private void simularCadastro(UsuarioDTO usuario) {
        // Simula delay de rede
        btnCadastrar.postDelayed(() -> {
            Toast.makeText(this, "Cadastro realizado com sucesso!", Toast.LENGTH_LONG).show();

            // Redireciona para login
            Intent intent = new Intent(this, LoginActivity.class);
            intent.putExtra("email", usuario.getEmail());
            startActivity(intent);
            finish();
        }, 1500);
    }

    /**
     * Validação final de todos os campos
     */
    private boolean validarTodosOsCampos() {
        boolean valido = true;

        // Força validação de todos os campos
        if (editNomeC.getText().toString().trim().isEmpty()) {
            layoutNome.setError("Nome é obrigatório");
            valido = false;
        }

        String cpf = editCPF.getText().toString().replaceAll("[^\\d]", "");
        if (cpf.isEmpty() || cpf.length() != 11 || !Utils.isCpfValido(cpf)) {
            layoutCPF.setError("CPF inválido");
            valido = false;
        }

        String email = editEmail.getText().toString().trim();
        if (email.isEmpty() || !Patterns.EMAIL_ADDRESS.matcher(email).matches()) {
            layoutEmail.setError("E-mail inválido");
            valido = false;
        }

        String telefone = editTelefone.getText().toString().replaceAll("[^\\d]", "");
        if (telefone.isEmpty() || telefone.length() < 10) {
            layoutTelefone.setError("Telefone inválido");
            valido = false;
        }

        String senha = editSenha.getText().toString();
        if (senha.isEmpty() || senha.length() < 6) {
            layoutSenha.setError("Senha deve ter pelo menos 6 caracteres");
            valido = false;
        }

        if (!senha.equals(editConSenha.getText().toString())) {
            layoutConSenha.setError("As senhas não coincidem");
            valido = false;
        }

        return valido;
    }

    @Override
    protected void onResume() {
        super.onResume();
        // Reabilita o botão caso tenha sido desabilitado
        btnCadastrar.setEnabled(true);
        btnCadastrar.setText("Cadastrar");
    }
}