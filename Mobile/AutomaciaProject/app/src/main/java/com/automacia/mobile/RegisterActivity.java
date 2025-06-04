package com.automacia.mobile;

import android.os.Bundle;
import android.text.Editable;
import android.text.TextWatcher;
import android.util.Patterns;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Toast;

import androidx.activity.EdgeToEdge;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;

public class RegisterActivity extends AppCompatActivity {
    private EditText editNomeC, editCPF, editEmail, editTelefone, editSenha, editConSenha;
    private Button btnCadastrar;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        EdgeToEdge.enable(this);
        setContentView(R.layout.activity_register);
        ViewCompat.setOnApplyWindowInsetsListener(findViewById(R.id.main), (v, insets) -> {
            Insets systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars());
            v.setPadding(systemBars.left, systemBars.top, systemBars.right, systemBars.bottom);
            return insets;
        });

        View mainview = findViewById(R.id.main);
        Utils.aplyGradientBackground(mainview);

        editNomeC = findViewById(R.id.editNomeC);
        editCPF = findViewById(R.id.editCPF);
        editEmail = findViewById(R.id.editEmail);
        editTelefone = findViewById(R.id.editTelefone);
        editSenha = findViewById(R.id.editSenha);
        editConSenha = findViewById(R.id.editConSenha);
        btnCadastrar = findViewById(R.id.btnRegistrar);

        editCPF.addTextChangedListener(new CpfMaskWatcher(editCPF));
        editCPF.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {

            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                String cpf = s.toString();

                if (cpf.length() == 11) {
                    if(!Utils.isCpfValido(cpf)) {
                        editCPF.setError("CPF inválido");
                    } else {
                        editCPF.setError(null);
                    }
                } else {
                    editCPF.setError(null);
                }
            }

            @Override
            public void afterTextChanged(Editable s) {

            }
        });

        btnCadastrar.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (validarCampos()) {
                    Toast.makeText(getBaseContext(), "Cadastro relalizado com sucesso!", Toast.LENGTH_SHORT).show();
                }
            }
        });
    }

    private boolean validarCampos() {
        String nome = editNomeC.getText().toString().trim();
        String cpf = editCPF.getText().toString().trim();
        String email = editEmail.getText().toString().trim();
        String telefone = editTelefone.getText().toString().trim();
        String senha = editSenha.getText().toString();
        String conSenha = editConSenha.getText().toString();

        if (nome.isEmpty()) {
            editNomeC.setError("Digite o nome completo!");
            return false;
        }

        if (email.isEmpty() || !Patterns.EMAIL_ADDRESS.matcher(email).matches()) {
            editEmail.setError("Digite um email válido");
            return false;
        }

        if (telefone.isEmpty() || telefone.length() < 9) {
            editTelefone.setError("Digite um telefone válido");
            return false;
        }

        if (senha.isEmpty() || senha.length() < 6) {
            editSenha.setError("Senha deve ter ao menos 6 caracteres");
            return false;
        }

        if (!senha.equals(conSenha)) {
            editConSenha.setError("As senhas não coincidem");
            return false;
        }

        return true;
    }
}