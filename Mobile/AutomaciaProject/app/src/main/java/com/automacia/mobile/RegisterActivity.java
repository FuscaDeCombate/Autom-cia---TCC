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
                String erro = Utils.validarNome(s.toString());
                layoutNome.setError(erro);
                isNomeValido = (erro == null);
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
                String erro = Utils.validarCpf(s.toString());
                layoutCPF.setError(erro);
                isCpfValido = (erro == null && Utils.extrairNumeros(s.toString()).length() == 11);
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
                String erro = Utils.validarEmail(s.toString());
                layoutEmail.setError(erro);
                isEmailValido = (erro == null);
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
                String erro = Utils.validarTelefone(s.toString());
                layoutTelefone.setError(erro);

                String telefoneNumeros = Utils.extrairNumeros(s.toString());
                isTelefoneValido = (erro == null && telefoneNumeros.length() >= 10 && telefoneNumeros.length() <= 11);
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
                String erro = Utils.validarSenha(s.toString());
                layoutSenha.setError(erro);
                isSenhaValida = (erro == null);

                //Revalida confirmação de senha
                if (!Utils.isCampoVazio(editConSenha.getText().toString())) {
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

        String erro = Utils.validarConfirmacaoSenha(senha, confirmacao);
        layoutConSenha.setError(erro);
        isConfirmacaoValida = (erro == null);
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
        // Utiliza a função de validação mútipla do Utils
        String primeiroErro = Utils.validarCampo(
                Utils.validarNome(editNomeC.getText().toString()),
                Utils.validarNome(editCPF.getText().toString()),
                Utils.validarEmail(editEmail.getText().toString()),
                Utils.validarTelefone(editTelefone.getText().toString()),
                Utils.validarSenha(editSenha.getText().toString()),
                Utils.validarConfirmacaoSenha(editSenha.getText().toString(), editConSenha.getText().toString())
        );

        if (primeiroErro != null) {
            // Aplica os erros individualmente para exibição
            layoutNome.setError(Utils.validarNome(editNomeC.getText().toString()));
            layoutCPF.setError(Utils.validarCpf(editCPF.getText().toString()));
            layoutEmail.setError(Utils.validarEmail(editEmail.getText().toString()));
            layoutTelefone.setError(Utils.validarTelefone(editTelefone.getText().toString()));
            layoutSenha.setError(Utils.validarSenha(editSenha.getText().toString()));
            layoutConSenha.setError(Utils.validarConfirmacaoSenha(editSenha.getText().toString(), editConSenha.getText().toString()));
            return false;
        }

        // Validações adicionais específicas
        String cpfNumeros = Utils.extrairNumeros(editCPF.getText().toString());
        if (cpfNumeros.length() != 11) {
            layoutCPF.setError("CPF deve ter 11 dígitos");
            return false;
        }

        String telefonesNumeros = Utils.extrairNumeros(editTelefone.getText().toString());
        if (telefonesNumeros.length() < 10 || telefonesNumeros.length() > 11) {
            layoutTelefone.setError("Telefone deve ter entre 10 a 11 dígitos");
            return false;
        }

        return true;
    }

    @Override
    protected void onResume() {
        super.onResume();
        // Reabilita o botão caso tenha sido desabilitado
        btnCadastrar.setEnabled(true);
        btnCadastrar.setText("Cadastrar");
    }
}