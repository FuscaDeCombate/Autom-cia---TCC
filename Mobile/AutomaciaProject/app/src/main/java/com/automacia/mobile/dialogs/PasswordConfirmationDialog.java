package com.automacia.mobile.dialogs;

import android.app.Dialog;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.animation.AlphaAnimation;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.DialogFragment;

import com.automacia.mobile.R;
import com.google.android.material.button.MaterialButton;
import com.google.android.material.textfield.TextInputEditText;
import com.google.android.material.textfield.TextInputLayout;

public class PasswordConfirmationDialog extends DialogFragment {
    private TextInputEditText etSenha;
    private TextInputLayout layoutSenha;
    private MaterialButton btnConfirmar;
    private PasswordConfirmationListener listener;

    public interface PasswordConfirmationListener {
        void onPasswordConfirmed(String password);
    }

    public static PasswordConfirmationDialog newInstance(PasswordConfirmationListener listener) {
        PasswordConfirmationDialog dialog = new PasswordConfirmationDialog();
        dialog.listener = listener;
        return dialog;
    }

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setStyle(DialogFragment.STYLE_NORMAL, R.style.DialogTheme);
    }

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container,
                             @Nullable Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.dialog_password_confirmation, container, false);

        etSenha = view.findViewById(R.id.et_senha_confirmacao);
        layoutSenha = view.findViewById(R.id.lay_senha_confirmacao);
        btnConfirmar = view.findViewById(R.id.btn_confirmar);

        btnConfirmar.setOnClickListener(v -> confirmarSenha());

        // Animação de fade in
        AlphaAnimation fadeIn = new AlphaAnimation(0f, 1f);
        fadeIn.setDuration(300);
        view.startAnimation(fadeIn);

        return view;
    }

    @Nullable
    @Override
    public Dialog onCreateDialog(@Nullable Bundle savedInstanceState) {
        Dialog dialog = super.onCreateDialog(savedInstanceState);

        // Remove o fundo para aplicar o nosso
        if (dialog.getWindow() != null) {
            dialog.getWindow().setBackgroundDrawableResource(android.R.color.transparent);
        }

        return dialog;
    }

    private void confirmarSenha() {
        String senha = etSenha.getText() != null ? etSenha.getText().toString() : "";

        if (senha.isEmpty()) {
            layoutSenha.setError("Digite sua senha");
            return;
        }

        layoutSenha.setError(null);
        btnConfirmar.setEnabled(false);
        btnConfirmar.setText("Verificando...");

        if (listener != null) {
            listener.onPasswordConfirmed(senha);
        }
    }

    public void resetButton() {
        if (btnConfirmar != null && isAdded()) {
            btnConfirmar.setEnabled(true);
            btnConfirmar.setText("Confirmar");
        }
    }

    public void showError(String message) {
        if (layoutSenha != null && isAdded()) {
            layoutSenha.setError(message);
        }
    }

    public void closeDialog() {
        if (isAdded()) {
            dismiss();
        }
    }
}