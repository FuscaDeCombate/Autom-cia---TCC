package com.automacia.mobile.fragments;

import android.content.Context;
import android.os.Bundle;
import android.os.CountDownTimer;
import android.os.Handler;
import android.os.Looper;
import android.text.Editable;
import android.text.TextWatcher;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;

import com.automacia.mobile.R;
import com.automacia.mobile.utils.Utils;
import com.google.android.material.button.MaterialButton;
import com.google.android.material.textfield.TextInputEditText;
import com.google.android.material.textfield.TextInputLayout;

/**
 * Fragment responsável por verificar o código de recuperação
 * Permite ao usuário inserir o código recebido por email
 */
public class VerifyCodeFragment extends Fragment {

    private static final String ARG_EMAIL = "email";
    private static final String ARG_CODE = "verification_code";
    private static final long COUNTDOWN_TIME = 300000; // 5 minutos em milliseconds
    private static final long COUNTDOWN_INTERVAL = 1000; // 1 segundo

    // Views
    private TextInputEditText editCodigo;
    private TextInputLayout layoutCodigo;
    private MaterialButton btnVerificarCodigo, btnReenviarCodigo;
    private TextView txtDescricao, txtCountdown;

    // Listener para comunicação com a Activity
    private OnCodeVerifiedListener listener;

    // Dados
    private String email;
    private String expectedCode;
    private CountDownTimer countDownTimer;

    // Validação
    private boolean isCodeValid = false;

    /**
     * Interface para comunicação com a Activity
     */
    public interface OnCodeVerifiedListener {
        void onCodeVerified();
        void onResendCodeRequested();
    }

    /**
     * Método factory para criar instância do fragment
     */
    public static VerifyCodeFragment newInstance(String email, String code) {
        VerifyCodeFragment fragment = new VerifyCodeFragment();
        Bundle args = new Bundle();
        args.putString(ARG_EMAIL, email);
        args.putString(ARG_CODE, code);
        fragment.setArguments(args);
        return fragment;
    }

    @Override
    public void onAttach(@NonNull Context context) {
        super.onAttach(context);
        if (context instanceof OnCodeVerifiedListener) {
            listener = (OnCodeVerifiedListener) context;
        } else {
            throw new RuntimeException(context.toString() + " deve implementar OnCodeVerifiedListener");
        }
    }

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        if (getArguments() != null) {
            email = getArguments().getString(ARG_EMAIL);
            expectedCode = getArguments().getString(ARG_CODE);
        }
    }

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_verify_code, container, false);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);

        initializeViews(view);
        setupValidators();
        setupClickListeners();
        updateDescriptionText();
        startCountdown();
    }

    /**
     * Inicializa as views
     */
    private void initializeViews(View view) {
        editCodigo = view.findViewById(R.id.editCodigo);
        layoutCodigo = view.findViewById(R.id.layoutCodigo);
        btnVerificarCodigo = view.findViewById(R.id.btnVerificarCodigo);
        btnReenviarCodigo = view.findViewById(R.id.btnReenviarCodigo);
        txtDescricao = view.findViewById(R.id.txtDescricao);
        txtCountdown = view.findViewById(R.id.txtCountdown);

        updateButtonState();
        btnReenviarCodigo.setEnabled(false); // Inicialmente desabilitado
    }

    /**
     * Configura os validadores
     */
    private void setupValidators() {
        editCodigo.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {}

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                String codigo = s.toString().trim();

                // Remove qualquer erro anterior
                layoutCodigo.setError(null);

                // Validação básica do código
                isCodeValid = !Utils.isCampoVazio(codigo) && codigo.length() == 6 && codigo.matches("\\d{6}");

                updateButtonState();
            }

            @Override
            public void afterTextChanged(Editable s) {}
        });
    }

    /**
     * Configura os listeners dos botões
     */
    private void setupClickListeners() {
        btnVerificarCodigo.setOnClickListener(v -> verifyCode());
        btnReenviarCodigo.setOnClickListener(v -> resendCode());
    }

    /**
     * Atualiza o texto de descrição com o email mascarado
     */
    private void updateDescriptionText() {
        if (email != null) {
            String emailMascarado = maskEmail(email);
            String descricao = "Digite o código de 6 dígitos enviado para " + emailMascarado;
            txtDescricao.setText(descricao);
        }
    }

    /**
     * Atualiza o estado do botão de verificar
     */
    private void updateButtonState() {
        btnVerificarCodigo.setEnabled(isCodeValid);
        btnVerificarCodigo.setAlpha(isCodeValid ? 1.0f : 0.6f);
    }

    /**
     * Inicia o countdown para reenvio
     */
    private void startCountdown() {
        if (countDownTimer != null) {
            countDownTimer.cancel();
        }

        countDownTimer = new CountDownTimer(COUNTDOWN_TIME, COUNTDOWN_INTERVAL) {
            @Override
            public void onTick(long millisUntilFinished) {
                long minutes = millisUntilFinished / 60000;
                long seconds = (millisUntilFinished % 60000) / 1000;

                String timeText = String.format("Reenviar código em %02d:%02d", minutes, seconds);
                txtCountdown.setText(timeText);
                txtCountdown.setVisibility(View.VISIBLE);
                btnReenviarCodigo.setEnabled(false);
                btnReenviarCodigo.setAlpha(0.6f);
            }

            @Override
            public void onFinish() {
                txtCountdown.setVisibility(View.GONE);
                btnReenviarCodigo.setEnabled(true);
                btnReenviarCodigo.setAlpha(1.0f);
            }
        };

        countDownTimer.start();
    }

    /**
     * Verifica o código inserido
     */
    private void verifyCode() {
        String codigoInserido = editCodigo.getText().toString().trim();

        if (!isCodeValid) {
            layoutCodigo.setError("Código deve ter 6 dígitos");
            return;
        }

        // Mostrar loading
        btnVerificarCodigo.setEnabled(false);
        btnVerificarCodigo.setText("Verificando...");

        // Simular verificação
        simulateCodeVerification(codigoInserido);
    }

    /**
     * Simula a verificação do código
     */
    private void simulateCodeVerification(String code) {
        new Handler(Looper.getMainLooper()).postDelayed(() -> {
            if (code.equals(expectedCode)) {
                // Código correto
                Toast.makeText(getContext(), "Código verificado com sucesso!", Toast.LENGTH_SHORT).show();

                if (listener != null) {
                    listener.onCodeVerified();
                }
            } else {
                // Código incorreto
                layoutCodigo.setError("Código incorreto. Tente novamente.");
                btnVerificarCodigo.setEnabled(true);
                btnVerificarCodigo.setText("Verificar Código");

                Toast.makeText(getContext(), "Código incorreto", Toast.LENGTH_SHORT).show();
            }
        }, 1500); // 1.5 segundos de delay
    }

    /**
     * Reenvia o código
     */
    private void resendCode() {
        Toast.makeText(getContext(), "Solicitando novo código...", Toast.LENGTH_SHORT).show();

        if (listener != null) {
            listener.onResendCodeRequested();
        }
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
                "*".repeat(username.length() - 2);

        return maskedUsername + "@" + domain;
    }

    @Override
    public void onDestroyView() {
        super.onDestroyView();
        if (countDownTimer != null) {
            countDownTimer.cancel();
        }
    }

    @Override
    public void onDetach() {
        super.onDetach();
        listener = null;
    }
}