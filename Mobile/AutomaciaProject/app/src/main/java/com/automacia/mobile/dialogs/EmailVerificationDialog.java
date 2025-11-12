package com.automacia.mobile.dialogs;

import android.app.Dialog;
import android.content.Context;
import android.os.Bundle;
import android.os.CountDownTimer;
import android.view.Window;
import android.view.animation.Animation;
import android.view.animation.AnimationUtils;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.NonNull;

import com.automacia.mobile.R;
import com.google.android.material.button.MaterialButton;

/**
 * Diálogo customizado para verificação de email
 * Segue Material Design com bordas arredondadas e animações fade
 */
public class EmailVerificationDialog extends Dialog {

    private TextView tvEmail;
    private TextView tvMessage;
    private TextView tvTimerInfo;
    private MaterialButton btnVerificar;
    private MaterialButton btnReenviar;
    private MaterialButton btnVoltar;
    private ImageView imgIcon;

    private String email;
    private EmailVerificationListener listener;

    // Timer para controle de reenvio
    private CountDownTimer countDownTimer;
    private boolean canResend = true;
    private static final long RESEND_COOLDOWN = 60000; // 60 segundos

    public interface EmailVerificationListener {
        void onVerifyClick();
        void onResendClick();
        void onBackClick();
    }

    public EmailVerificationDialog(@NonNull Context context, String email, EmailVerificationListener listener) {
        super(context, R.style.DialogTheme);
        this.email = email;
        this.listener = listener;
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.dialog_email_verification);

        // Configura o fundo transparente para mostrar as bordas arredondadas
        if (getWindow() != null) {
            getWindow().setBackgroundDrawableResource(android.R.color.transparent);
        }

        initializeViews();
        setupClickListeners();
        setupAnimations();

        // Dialog não pode ser cancelado clicando fora
        setCancelable(false);
        setCanceledOnTouchOutside(false);
    }

    private void initializeViews() {
        imgIcon = findViewById(R.id.imgEmailIcon);
        tvEmail = findViewById(R.id.tvEmail);
        tvMessage = findViewById(R.id.tvMessage);
        tvTimerInfo = findViewById(R.id.tvTimerInfo);
        btnVerificar = findViewById(R.id.btnVerificar);
        btnReenviar = findViewById(R.id.btnReenviar);
        btnVoltar = findViewById(R.id.btnVoltar);

        // Define o email
        tvEmail.setText(email);

        // Esconde o timer inicialmente
        tvTimerInfo.setVisibility(TextView.GONE);
    }

    private void setupClickListeners() {
        btnVerificar.setOnClickListener(v -> {
            if (listener != null) {
                listener.onVerifyClick();
            }
        });

        btnReenviar.setOnClickListener(v -> {
            if (canResend && listener != null) {
                listener.onResendClick();
                startResendTimer();
            }
        });

        btnVoltar.setOnClickListener(v -> {
            if (listener != null) {
                listener.onBackClick();
            }
            dismiss();
        });
    }

    private void setupAnimations() {
        // Animação de fade in para o diálogo
        Animation fadeIn = AnimationUtils.loadAnimation(getContext(), R.anim.fade_in);
        findViewById(R.id.dialogContainer).startAnimation(fadeIn);
    }

    /**
     * Inicia o timer de cooldown para reenvio de email
     */
    private void startResendTimer() {
        canResend = false;
        btnReenviar.setEnabled(false);
        btnReenviar.setAlpha(0.5f);
        tvTimerInfo.setVisibility(TextView.VISIBLE);

        countDownTimer = new CountDownTimer(RESEND_COOLDOWN, 1000) {
            @Override
            public void onTick(long millisUntilFinished) {
                long seconds = millisUntilFinished / 1000;
                tvTimerInfo.setText(String.format("Aguarde %d segundos para reenviar", seconds));
            }

            @Override
            public void onFinish() {
                canResend = true;
                btnReenviar.setEnabled(true);
                btnReenviar.setAlpha(1.0f);
                tvTimerInfo.setVisibility(TextView.GONE);
            }
        }.start();
    }

    @Override
    public void dismiss() {
        // Animação de fade out antes de fechar
        Animation fadeOut = AnimationUtils.loadAnimation(getContext(), R.anim.fade_out);
        fadeOut.setAnimationListener(new Animation.AnimationListener() {
            @Override
            public void onAnimationStart(Animation animation) {}

            @Override
            public void onAnimationEnd(Animation animation) {
                EmailVerificationDialog.super.dismiss();
            }

            @Override
            public void onAnimationRepeat(Animation animation) {}
        });

        findViewById(R.id.dialogContainer).startAnimation(fadeOut);
    }

    @Override
    protected void onStop() {
        super.onStop();
        // Cancela o timer quando o diálogo é fechado
        if (countDownTimer != null) {
            countDownTimer.cancel();
        }
    }

    /**
     * Atualiza o email exibido no diálogo
     */
    public void updateEmail(String newEmail) {
        this.email = newEmail;
        if (tvEmail != null) {
            tvEmail.setText(newEmail);
        }
    }

    /**
     * Reseta o timer de reenvio (útil quando o reenvio é bem-sucedido)
     */
    public void resetResendTimer() {
        if (countDownTimer != null) {
            countDownTimer.cancel();
        }
        startResendTimer();
    }
}