package com.automacia.mobile;

import android.content.Intent;
import android.os.Bundle;
import android.text.Editable;
import android.text.TextWatcher;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Switch;
import android.widget.TextView;
import android.widget.Toast;

import androidx.activity.EdgeToEdge;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;

public class LoginActivity extends AppCompatActivity {
    EditText editCpf, editSenha;
    Button btnLogin;
    Switch swLembrar;
    TextView txtEsqueciSenha, txtCadastro;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        EdgeToEdge.enable(this);
        setContentView(R.layout.activity_login);
        ViewCompat.setOnApplyWindowInsetsListener(findViewById(R.id.main), (v, insets) -> {
            Insets systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars());
            v.setPadding(systemBars.left, systemBars.top, systemBars.right, systemBars.bottom);
            return insets;
        });

        View mainview = findViewById(R.id.main);
        Utils.aplyGradientBackground(mainview);

        editCpf = findViewById(R.id.editCpf);
        editSenha = findViewById(R.id.editSenha);
        btnLogin = findViewById(R.id.btnLogin);
        swLembrar = findViewById(R.id.switchLembrar);
        txtEsqueciSenha = findViewById(R.id.txtEsqueciSenha);
        txtCadastro = findViewById(R.id.txtCadastro);

        editCpf.addTextChangedListener(new CpfMaskWatcher(editCpf));

        editCpf.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {

            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                String cpf = s.toString();

                if (cpf.length() == 11) {
                    if (!Utils.isCpfValido(cpf)) {
                        editCpf.setError("CPF inválido");
                    } else {
                        editCpf.setError(null);
                    }
                } else {
                    editCpf.setError(null);
                }
            }

            @Override
            public void afterTextChanged(Editable s) {

            }
        });

        btnLogin.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                String cpf = editCpf.getText().toString();
                String senha = editCpf.getText().toString();

                if (cpf.isEmpty() || senha.isEmpty()) {
                    Toast.makeText(getBaseContext(), "Preencha todos os campos", Toast.LENGTH_SHORT).show();
                } else {
                    Toast.makeText(getBaseContext(), "Login realizado (mock)", Toast.LENGTH_SHORT).show();
                    Intent i = new Intent(getBaseContext(), MainActivity.class);
                    startActivity(i);
                    finish();
                }
            }
        });

        txtEsqueciSenha.setOnClickListener(v -> {
            Toast.makeText(getBaseContext(), "Recuperção de senha", Toast.LENGTH_SHORT).show();
        });

        txtCadastro.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent i = new Intent(getBaseContext(), RegisterActivity.class);
                startActivity(i);
                finish();
            }
        });
    }
}