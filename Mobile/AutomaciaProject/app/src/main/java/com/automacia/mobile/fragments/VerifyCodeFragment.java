package com.automacia.mobile.fragments;

import android.animation.ObjectAnimator;
import android.content.ClipData;
import android.content.ClipboardManager;
import android.content.Context;
import android.os.Bundle;
import android.os.CountDownTimer;
import android.os.Handler;
import android.os.Looper;
import android.os.Vibrator;
import android.text.Editable;
import android.text.TextWatcher;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;

import com.automacia.mobile.R;
import com.google.android.material.button.MaterialButton;
import com.google.android.material.textfield.TextInputEditText;
import com.google.android.material.textfield.TextInputLayout;

/**
 * Fragment responsável por verificar o código de recuperação
 * Permite ao usuário inserir o código recebido por email
 */
public class VerifyCodeFragment extends Fragment {

    // Constantes
    private static final String ARG_EMAIL = "email";
    private static final String ARG_CODE = "verification_code";
    private static final long COUNTDOWN_TIME = 300000; // 5 minutos em milliseconds
    private static final long COUNTDOWN_INTERVAL = 1000; // 1 segundo
    private static final int CODE_LENGTH = 6;
    private static final int COUNTDOWN_MINUTES = 5;
    private static final int VERIFICATION_DELAY_MS = 1500;
    private static final int AUTO_SUBMIT_DELAY_MS = 500;
    private static final int VIBRATION_DURATION_MS = 100;
    private static final int ERROR_ANIMATION_DURATION_MS = 600;

    // Views - campos individuais
    private TextInputEditText editCodigo1, editCodigo2, editCodigo3, editCodigo4, editCodigo5, editCodigo6;
    private TextInputLayout layoutCodigo1, layoutCodigo2, layoutCodigo3, layoutCodigo4, layoutCodigo5, layoutCodigo6;
    private TextInputEditText[] codeInputs;
    private TextInputLayout[] codeLayouts;

    // Views originais (para compatibilidade)
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
    private boolean isVerifying = false;

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
        setupCodeInputs();
        setupPasteHandling();
        setupAccessibility();
        setupClickListeners();
        updateDescriptionText();
        startCountdown();
    }

    /**
     * Inicializa as views
     */
    private void initializeViews(View view) {
        // Campos individuais
        editCodigo1 = view.findViewById(R.id.editCodigo1);
        editCodigo2 = view.findViewById(R.id.editCodigo2);
        editCodigo3 = view.findViewById(R.id.editCodigo3);
        editCodigo4 = view.findViewById(R.id.editCodigo4);
        editCodigo5 = view.findViewById(R.id.editCodigo5);
        editCodigo6 = view.findViewById(R.id.editCodigo6);

        layoutCodigo1 = view.findViewById(R.id.layoutCodigo1);
        layoutCodigo2 = view.findViewById(R.id.layoutCodigo2);
        layoutCodigo3 = view.findViewById(R.id.layoutCodigo3);
        layoutCodigo4 = view.findViewById(R.id.layoutCodigo4);
        layoutCodigo5 = view.findViewById(R.id.layoutCodigo5);
        layoutCodigo6 = view.findViewById(R.id.layoutCodigo6);

        // Arrays para facilitar manipulação
        codeInputs = new TextInputEditText[]{editCodigo1, editCodigo2, editCodigo3, editCodigo4, editCodigo5, editCodigo6};
        codeLayouts = new TextInputLayout[]{layoutCodigo1, layoutCodigo2, layoutCodigo3, layoutCodigo4, layoutCodigo5, layoutCodigo6};

        // Views originais (ocultas, para compatibilidade)
        editCodigo = view.findViewById(R.id.editCodigo);
        layoutCodigo = view.findViewById(R.id.layoutCodigo);

        // Outras views
        btnVerificarCodigo = view.findViewById(R.id.btnVerificarCodigo);
        btnReenviarCodigo = view.findViewById(R.id.btnReenviarCodigo);
        txtDescricao = view.findViewById(R.id.txtDescricao);
        txtCountdown = view.findViewById(R.id.txtCountdown);

        updateButtonState();
        btnReenviarCodigo.setEnabled(false);

        // Foco inicial no primeiro campo
        editCodigo1.requestFocus();
    }

    /**
     * Configura os campos de código individuais
     */
    private void setupCodeInputs() {
        for (int i = 0; i < codeInputs.length; i++) {
            final int currentIndex = i;
            final TextInputEditText currentInput = codeInputs[i];

            currentInput.addTextChangedListener(new TextWatcher() {
                @Override
                public void beforeTextChanged(CharSequence s, int start, int count, int after) {}

                @Override
                public void onTextChanged(CharSequence s, int start, int before, int count) {
                    String text = s.toString();

                    // Remove erros
                    clearAllErrors();

                    if (text.length() == 1) {
                        // Move para o próximo campo
                        if (currentIndex < codeInputs.length - 1) {
                            codeInputs[currentIndex + 1].requestFocus();
                        }
                    }

                    // Atualiza o campo oculto para compatibilidade
                    updateHiddenCodeField();

                    // Valida código completo
                    validateCode();
                }

                @Override
                public void afterTextChanged(Editable s) {}
            });

            // Configura backspace para voltar ao campo anterior
            currentInput.setOnKeyListener((v, keyCode, event) -> {
                if (keyCode == KeyEvent.KEYCODE_DEL && event.getAction() == KeyEvent.ACTION_DOWN) {
                    if (currentInput.getText().toString().isEmpty() && currentIndex > 0) {
                        codeInputs[currentIndex - 1].requestFocus();
                        return true;
                    }
                }
                return false;
            });

            // Foco e seleção
            currentInput.setOnFocusChangeListener((v, hasFocus) -> {
                if (hasFocus) {
                    currentInput.selectAll();
                    // Adiciona destaque visual ao campo focado
                    codeLayouts[currentIndex].setBoxStrokeWidth(3);
                } else {
                    codeLayouts[currentIndex].setBoxStrokeWidth(2);
                }
            });
        }
    }

    /**
     * Configura tratamento de colar (paste) no código
     */
    private void setupPasteHandling() {
        editCodigo1.setOnLongClickListener(v -> {
            if (getContext() == null) return false;

            // Interceptar paste para distribuir entre os campos
            ClipboardManager clipboard = (ClipboardManager) getContext().getSystemService(Context.CLIPBOARD_SERVICE);
            if (clipboard != null && clipboard.hasPrimaryClip()) {
                ClipData.Item item = clipboard.getPrimaryClip().getItemAt(0);
                if (item != null && item.getText() != null) {
                    String pastedText = item.getText().toString().replaceAll("\\D", ""); // Só números

                    if (pastedText.length() == CODE_LENGTH) {
                        distributeCodeToFields(pastedText);
                        Toast.makeText(getContext(), "Código colado automaticamente", Toast.LENGTH_SHORT).show();
                        return true;
                    } else {
                        Toast.makeText(getContext(), "Código deve ter " + CODE_LENGTH + " dígitos", Toast.LENGTH_SHORT).show();
                    }
                }
            }
            return false;
        });
    }

    /**
     * Distribui o código colado entre os campos
     */
    private void distributeCodeToFields(String code) {
        for (int i = 0; i < Math.min(code.length(), codeInputs.length); i++) {
            codeInputs[i].setText(String.valueOf(code.charAt(i)));
        }
        // Foca no último campo preenchido
        if (code.length() <= codeInputs.length) {
            codeInputs[Math.min(code.length() - 1, codeInputs.length - 1)].requestFocus();
        }
        validateCode();
    }

    /**
     * Configura acessibilidade
     */
    private void setupAccessibility() {
        for (int i = 0; i < codeInputs.length; i++) {
            codeInputs[i].setContentDescription("Dígito " + (i + 1) + " do código de verificação");
            codeLayouts[i].setHint("Dígito " + (i + 1));
        }

        txtDescricao.setContentDescription("Instruções: Digite o código de " + CODE_LENGTH +
                " dígitos enviado para " + (email != null ? maskEmail(email) : "seu email"));

        btnVerificarCodigo.setContentDescription("Verificar código de recuperação");
        btnReenviarCodigo.setContentDescription("Reenviar código de verificação");
    }

    /**
     * Configura os listeners dos botões
     */
    private void setupClickListeners() {
        btnVerificarCodigo.setOnClickListener(v -> verifyCode());
        btnReenviarCodigo.setOnClickListener(v -> resendCode());
    }

    /**
     * Atualiza o campo oculto para manter compatibilidade com código existente
     */
    private void updateHiddenCodeField() {
        StringBuilder code = new StringBuilder();
        for (TextInputEditText input : codeInputs) {
            code.append(input.getText().toString());
        }
        editCodigo.setText(code.toString());
    }

    /**
     * Valida o código completo com auto-submit
     */
    private void validateCode() {
        String fullCode = getFullCode();
        isCodeValid = fullCode.length() == CODE_LENGTH &&
                fullCode.matches("\\d{" + CODE_LENGTH + "}");
        updateButtonState();

        // Auto-submit quando código completo, válido e não está verificando
        if (isCodeValid && btnVerificarCodigo.isEnabled() && !isVerifying) {
            new Handler(Looper.getMainLooper()).postDelayed(this::verifyCode, AUTO_SUBMIT_DELAY_MS);
        }
    }

    /**
     * Obtém o código completo dos campos individuais
     */
    private String getFullCode() {
        StringBuilder code = new StringBuilder();
        for (TextInputEditText input : codeInputs) {
            code.append(input.getText().toString().trim());
        }
        return code.toString();
    }

    /**
     * Remove todos os erros visuais
     */
    private void clearAllErrors() {
        for (TextInputLayout layout : codeLayouts) {
            layout.setError(null);
        }
        layoutCodigo.setError(null);
    }

    /**
     * Mostra erro visual nos campos com animação e vibração
     */
    private void showCodeError(String message) {
        // Animação sutil de shake nos campos
        for (TextInputLayout layout : codeLayouts) {
            layout.setError(" "); // Espaço para mostrar cor de erro sem texto

            // Adicionar animação de shake
            ObjectAnimator.ofFloat(layout, "translationX", 0, 25, -25, 25, -25, 15, -15, 6, -6, 0)
                    .setDuration(ERROR_ANIMATION_DURATION_MS)
                    .start();
        }

        layoutCodigo.setError(message); // Mensagem no campo oculto para compatibilidade

        // Vibração tátil
        if (getContext() != null) {
            Vibrator vibrator = (Vibrator) getContext().getSystemService(Context.VIBRATOR_SERVICE);
            if (vibrator != null && vibrator.hasVibrator()) {
                vibrator.vibrate(VIBRATION_DURATION_MS);
            }
        }
    }

    /**
     * Limpa todos os campos
     */
    private void clearAllFields() {
        for (TextInputEditText input : codeInputs) {
            input.setText("");
        }
        editCodigo1.requestFocus();
    }

    /**
     * Atualiza o texto de descrição com o email mascarado
     */
    private void updateDescriptionText() {
        if (email != null) {
            String emailMascarado = maskEmail(email);
            String descricao = "Digite o código de " + CODE_LENGTH + " dígitos enviado para " + emailMascarado;
            txtDescricao.setText(descricao);
        }
    }

    /**
     * Atualiza o estado do botão de verificar
     */
    private void updateButtonState() {
        boolean enabled = isCodeValid && !isVerifying;
        btnVerificarCodigo.setEnabled(enabled);
        btnVerificarCodigo.setAlpha(enabled ? 1.0f : 0.6f);
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
                btnReenviarCodigo.setContentDescription("Reenviar código de verificação - disponível agora");
            }
        };

        countDownTimer.start();
    }

    /**
     * Verifica o código inserido
     */
    private void verifyCode() {
        String codigoInserido = getFullCode();

        if (!isCodeValid) {
            showCodeError("Código deve ter " + CODE_LENGTH + " dígitos");
            return;
        }

        if (isVerifying) {
            return; // Evita múltiplas verificações simultâneas
        }

        // Mostrar loading
        isVerifying = true;
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
            isVerifying = false;

            if (code.equals(expectedCode)) {
                // Código correto
                Toast.makeText(getContext(), "Código verificado com sucesso!", Toast.LENGTH_SHORT).show();

                if (listener != null) {
                    listener.onCodeVerified();
                }
            } else {
                // Código incorreto
                showCodeError("Código incorreto. Tente novamente.");
                btnVerificarCodigo.setText("Verificar Código");
                updateButtonState();

                // Limpa os campos e redefine foco
                clearAllFields();
                Toast.makeText(getContext(), "Código incorreto", Toast.LENGTH_SHORT).show();
            }
        }, VERIFICATION_DELAY_MS);
    }

    /**
     * Reenvia o código
     */
    private void resendCode() {
        Toast.makeText(getContext(), "Solicitando novo código...", Toast.LENGTH_SHORT).show();
        clearAllFields();
        clearAllErrors();
        startCountdown();

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
                "*".repeat(Math.max(0, username.length() - 2));

        return maskedUsername + "@" + domain;
    }

    @Override
    public void onDestroyView() {
        super.onDestroyView();
        if (countDownTimer != null) {
            countDownTimer.cancel();
            countDownTimer = null;
        }
    }

    @Override
    public void onDetach() {
        super.onDetach();
        listener = null;
    }
}