package com.automacia.mobile.fragments;

import android.content.Context;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.text.Editable;
import android.text.TextWatcher;
import android.util.Patterns;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;

import com.automacia.mobile.R;
import com.automacia.mobile.services.EmailService;
import com.google.android.material.button.MaterialButton;
import com.google.android.material.textfield.TextInputEditText;
import com.google.android.material.textfield.TextInputLayout;

import java.util.Random;

/**
 * Fragment responsável por solicitar o código de recuperação
 * Permite ao usuário inserir email para receber código de verificação
 */
public class SendCodeFragment extends Fragment {

    // Views
    private TextInputEditText editEmail;
    private TextInputLayout layoutEmail;
    private MaterialButton btnEnviarCodigo;
    private TextView txtDescricao;

    // Services
    private EmailService emailService;

    // Listener para comunicação com a Activity
    private OnCodeSentListener listener;

    // Validação
    private boolean isEmailValid = false;

    /**
     * Interface para comunicação com a Activity
     */
    public interface OnCodeSentListener {
        void onCodeSent(String email, String code);
    }

    /**
     * Método factory para criar instância do fragment
     */
    public static SendCodeFragment newInstance() {
        return new SendCodeFragment();
    }

    @Override
    public void onAttach(@NonNull Context context) {
        super.onAttach(context);
        if (context instanceof OnCodeSentListener) {
            listener = (OnCodeSentListener) context;
        } else {
            throw new RuntimeException(context.toString() + " deve implementar OnCodeSentListener");
        }
    }

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        emailService = new EmailService();
    }

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_send_code, container, false);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);

        initializeViews(view);
        setupValidators();
        setupClickListeners();
    }

    /**
     * Inicializa as views
     */
    private void initializeViews(View view) {
        editEmail = view.findViewById(R.id.editEmail);
        layoutEmail = view.findViewById(R.id.layoutEmail);
        btnEnviarCodigo = view.findViewById(R.id.btnEnviarCodigo);
        txtDescricao = view.findViewById(R.id.txtDescricao);

        updateButtonState();
    }

    /**
     * Configura os validadores de email
     */
    private void setupValidators() {
        editEmail.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {}

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                String email = s.toString().trim();

                if (email.isEmpty()) {
                    layoutEmail.setError(null);
                    isEmailValid = false;
                } else if (!isValidEmail(email)) {
                    layoutEmail.setError("Email inválido");
                    isEmailValid = false;
                } else {
                    layoutEmail.setError(null);
                    isEmailValid = true;
                }

                updateButtonState();
            }

            @Override
            public void afterTextChanged(Editable s) {}
        });
    }

    /**
     * Valida formato do email
     */
    private boolean isValidEmail(String email) {
        return email != null &&
                !email.trim().isEmpty() &&
                Patterns.EMAIL_ADDRESS.matcher(email.trim()).matches() &&
                email.length() <= 254; // RFC 5321 limit
    }

    /**
     * Configura os listeners dos botões
     */
    private void setupClickListeners() {
        btnEnviarCodigo.setOnClickListener(v -> sendVerificationCode());
    }

    /**
     * Atualiza o estado do botão
     */
    private void updateButtonState() {
        btnEnviarCodigo.setEnabled(isEmailValid);
        btnEnviarCodigo.setAlpha(isEmailValid ? 1.0f : 0.6f);
    }

    /**
     * Envia o código de verificação
     */
    private void sendVerificationCode() {
        if (!isEmailValid) {
            Toast.makeText(getContext(), "Por favor, insira um email válido", Toast.LENGTH_SHORT).show();
            return;
        }

        String email = editEmail.getText().toString().trim();

        // Mostrar loading
        btnEnviarCodigo.setEnabled(false);
        btnEnviarCodigo.setText("Enviando...");

        // TODO: Implementar verificação real se email existe no banco de dados
        // Por enquanto, simular verificação
        simulateEmailVerification(email);
    }

    /**
     * Simula verificação se email existe no banco
     * TODO: Substituir por chamada real da API/procedure do banco
     */
    private void simulateEmailVerification(String email) {
        new Handler(Looper.getMainLooper()).postDelayed(() -> {
            // Simular que email existe (em produção, verificar no banco)
            boolean emailExists = true; // TODO: Chamar procedure do banco para verificar

            if (!emailExists) {
                // Reset button
                btnEnviarCodigo.setEnabled(true);
                btnEnviarCodigo.setText("Enviar Código");

                layoutEmail.setError("Email não encontrado em nossa base de dados");
                Toast.makeText(getContext(),
                        "Email não encontrado. Verifique se está correto ou registre-se primeiro.",
                        Toast.LENGTH_LONG).show();
                return;
            }

            // Email existe, enviar código
            String verificationCode = generateRandomCode();
            sendCodeByEmail(email, verificationCode);

        }, 1000); // 1 segundo de delay para simular consulta
    }

    /**
     * Envia código por email usando EmailService
     */
    private void sendCodeByEmail(String email, String code) {
        emailService.enviarCodigoRecuperacao(email, code, new EmailService.EmailCallback() {
            @Override
            public void onSuccess() {
                if (getActivity() != null) {
                    getActivity().runOnUiThread(() -> {
                        // Reset button
                        btnEnviarCodigo.setEnabled(true);
                        btnEnviarCodigo.setText("Enviar Código");

                        Toast.makeText(getContext(),
                                "Código enviado para " + maskEmail(email),
                                Toast.LENGTH_LONG).show();

                        // Notificar a Activity
                        if (listener != null) {
                            listener.onCodeSent(email, code);
                        }
                    });
                }
            }

            @Override
            public void onError(String error) {
                if (getActivity() != null) {
                    getActivity().runOnUiThread(() -> {
                        // Reset button
                        btnEnviarCodigo.setEnabled(true);
                        btnEnviarCodigo.setText("Enviar Código");

                        Toast.makeText(getContext(),
                                "Erro ao enviar código. Tente novamente.",
                                Toast.LENGTH_SHORT).show();
                    });
                }
            }
        });
    }

    /**
     * Gera código aleatório de 6 dígitos
     */
    private String generateRandomCode() {
        Random random = new Random();
        return String.format("%06d", random.nextInt(1000000));
    }

    /**
     * Mascara o email para exibição
     */
    private String maskEmail(String email) {
        if (email == null || !email.contains("@")) {
            return email;
        }

        String[] parts = email.split("@");
        String username = parts[0];
        String domain = parts[1];

        if (username.length() <= 2) {
            return email;
        }

        String maskedUsername = username.substring(0, 2) +
                "*".repeat(Math.max(0, username.length() - 2));

        return maskedUsername + "@" + domain;
    }

    @Override
    public void onDetach() {
        super.onDetach();
        listener = null;
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        if (emailService != null) {
            emailService.shutdown();
            emailService = null;
        }
    }
}