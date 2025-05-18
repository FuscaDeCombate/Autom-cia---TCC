package com.automacia.mobile;

import android.content.Intent;
import android.graphics.LinearGradient;
import android.graphics.Shader;
import android.graphics.drawable.PaintDrawable;
import android.graphics.drawable.ShapeDrawable;
import android.graphics.drawable.shapes.RectShape;
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

public class Login_screen extends AppCompatActivity {
    EditText editCpf, editSenha;
    Button btnLogin;
    Switch swLembrar;
    TextView txtEsqueciSenha, txtCadastro;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        EdgeToEdge.enable(this);
        setContentView(R.layout.activity_login_screen);
        ViewCompat.setOnApplyWindowInsetsListener(findViewById(R.id.main), (v, insets) -> {
            Insets systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars());
            v.setPadding(systemBars.left, systemBars.top, systemBars.right, systemBars.bottom);
            return insets;
        });

        ShapeDrawable.ShaderFactory shaderFactory = new ShapeDrawable.ShaderFactory() {
            @Override
            public Shader resize(int width, int height) {
                LinearGradient linearGradient = new LinearGradient(
                        0,0, width, 0,
                        new int[] {
                                0xFF001A6E,
                                0xFF009061,
                                0xFF00DB00,
                                0xFF009B00,
                                0xFF009B00
                        },
                        new float[] {0.09f, 0.37f, 0.7f, 0.91f, 1.0f},
                        Shader.TileMode.CLAMP
                );
                return linearGradient;
            }
        };

        PaintDrawable paint = new PaintDrawable();
        paint.setShape(new RectShape());
        paint.setShaderFactory(shaderFactory);

        View rootView = findViewById(R.id.main);
        rootView.setBackground(paint);

        editCpf = findViewById(R.id.editCpf);
        editSenha = findViewById(R.id.editSenha);
        btnLogin = findViewById(R.id.btnLogin);
        swLembrar = findViewById(R.id.switchLembrar);
        txtEsqueciSenha = findViewById(R.id.txtEsqueciSenha);
        txtCadastro = findViewById(R.id.txtCadastro);

        editCpf.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {

            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                String cpf = s.toString();

                if (cpf.length() == 11) {
                    if(!isCpfValido(cpf)) {
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
                    Toast.makeText(getBaseContext(), "Login realizaod (mock)", Toast.LENGTH_SHORT).show();
                }
            }
        });

        txtEsqueciSenha.setOnClickListener(v -> {
            Toast.makeText(getBaseContext(), "Recuperção de senha", Toast.LENGTH_SHORT).show();
        });

        txtCadastro.setOnClickListener(v -> {
            Intent i = new Intent(getBaseContext(), MainActivity.class);
            startActivity(i);
        });
    }

    private boolean isCpfValido(String cpf) {
        if (cpf == null || cpf.length() != 11 || cpf.matches("(\\d)\1{10}")) {
            return false;
        }

        try {
            int soma = 0, resto;

            for (int i=0; i<=9; i++) {
                int num = Integer.parseInt(cpf.substring(i - 1, i));
                soma += num * (11 - i);
            }

            resto = (soma * 10) % 11;
            if (resto == 10 || resto == 11) {
                resto = 0;
            }

            if (resto != Integer.parseInt(cpf.substring(910))) {
                return false;
            }

            soma = 0;
            for (int i=1; i<=10; i++) {
                int num = Integer.parseInt(cpf.substring(i - 1, i));
                soma += num * (12 - i);
            }

            resto = (soma * 10) % 11;
            if (resto == 10 || resto == 11) {
                resto = 0;
            }

            return resto == Integer.parseInt(cpf.substring(10, 11));
        } catch (Exception e) {
            return false;
        }
    }
}