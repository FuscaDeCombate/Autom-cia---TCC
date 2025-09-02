package com.automacia.mobile.fragments;

import android.content.Context;
import android.os.Bundle;
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
 * Fragment responsável por redefinir a senha
 * Permite ao usuário inserir uma nova senha após verificação do código
 */
public class ResetPasswordFragment extends Fragment {

    private static final String ARG_CPF = "cpf";

    // Views
    private TextInputEditText editNovaSenha, editConfirmarSenha;
    private TextInputLayout layoutNovaSenha, layoutConfirmarSenha;
    private MaterialButton btnRedefinirSenha;
    private TextView txtDescricao;

    // Listener para comunicação com a Activity
    private OnPasswordResetListener listener;

    // Dados
    private String cpf;

    // Validação
    private boolean isNovaSenhaValid = false;
    private boolean isConfirmacaoValid = false;

    /**
     * Interface para comunicação com a Activity
     */
    public interface OnPasswordResetListener {
        void onPasswordReset();
    }

    /**
     * Método factory para criar instância do fragment
     */
    public static ResetPasswordFragment newInstance(String cpf) {
        ResetPasswordFragment fragment = new ResetPasswordFragment();
        Bundle args = new Bundle();
        args.putString(ARG_CPF, cpf);
        fragment.setArguments(args);
        return fragment;
    }

    @Override
    public void onAttach(@NonNull Context context) {
        super.onAttach(context);
        if (context instanceof OnPasswordResetListener) {
            listener = (OnPasswordResetListener) context;
        } else {
            throw new RuntimeException(context.toString() + " deve implementar OnPasswordResetListener");
        }
    }

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        if (getArguments() != null) {
            cpf = getArguments().getString(ARG_CPF);
        }
    }

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_reset_password, container, false);
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
        editNovaSenha = view.findViewById(R.id.editNovaSenha);
        editConfirmarSenha = view.findViewById(R.id.editConfirmarSenha);
        layoutNovaSenha = view.findViewById(R.id.layoutNovaSenha);
        layoutConfirmarSenha = view.findViewById(R.id.layoutConfirmarSenha);
        btnRedefinirSenha = view.findViewById(R.id.btnRedefinirSenha);
        txtDescricao = view.findViewById(R.id.txtDescricao);

        updateButtonState();
    }

    /**
     * Configura os validadores usando Utils
     */
    private void setupValidators() {
        // Validador da nova senha
        editNovaSenha.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {}

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                String erro = Utils.validarSenha(s.toString());
                layoutNovaSenha.setError(erro);
                isNovaSenhaValid = (erro == null);

                // Revalidar confirmação se já foi preenchida
                String confirmacao = editConfirmarSenha.getText().toString();
                if (!Utils.isCampoVazio(confirmacao)) {
                    validarConfirmacao();
                }

                updateButtonState();
            }

            @Override
            public void afterTextChanged(Editable s) {}
        });

        // Validador da confirmação de senha
        editConfirmarSenha.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {}

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                validarConfirmacao();
                updateButtonState();
            }

            @Override
            public void afterTextChanged(Editable s) {}
        });
    }

    /**
     * Valida a confirmação de senha
     */
    private void validarConfirmacao() {
        String novaSenha = editNovaSenha.getText().toString();
        String confirmacao = editConfirmarSenha.getText().toString();

        String erro = Utils.validarConfirmacaoSenha(novaSenha, confirmacao);
        layoutConfirmarSenha.setError(erro);
        isConfirmacaoValid = (erro == null);
    }

    /**
     * Configura os listeners dos botões
     */
    private void setupClickListeners() {
        btnRedefinirSenha.setOnClickListener(v -> resetPassword());
    }

    /**
     * Atualiza o estado do botão
     */
    private void updateButtonState() {
        boolean isEnabled = isNovaSenhaValid && isConfirmacaoValid;
        btnRedefinirSenha.setEnabled(isEnabled);
        btnRedefinirSenha.setAlpha(isEnabled ? 1.0f : 0.6f);
    }

    /**
     * Redefine a senha
     */
    private void resetPassword() {
        // Validação final
        if (!validarTodosOsCampos()) {
            Toast.makeText(getContext(), "Por favor, corrija os erros antes de continuar", Toast.LENGTH_SHORT).show();
            return;
        }

        String novaSenha = editNovaSenha.getText().toString();

        // Mostrar loading
        btnRedefinirSenha.setEnabled(false);
        btnRedefinirSenha.setText("Redefinindo...");

        // Simular chamada de API
        simulatePasswordReset(cpf, novaSenha);
    }

    /**
     * Validação final de todos os campos
     */
    private boolean validarTodosOsCampos() {
        String novaSenha = editNovaSenha.getText().toString();
        String confirmacao = editConfirmarSenha.getText().toString();

        // Utiliza a função de validação múltipla do Utils
        String primeiroErro = Utils.validarCampo(
                Utils.validarSenha(novaSenha),
                Utils.validarConfirmacaoSenha(novaSenha, confirmacao)
        );

        if (primeiroErro != null) {
            // Aplica os erros individualmente para exibição
            layoutNovaSenha.setError(Utils.validarSenha(novaSenha));
            layoutConfirmarSenha.setError(Utils.validarConfirmacaoSenha(novaSenha, confirmacao));
            return false;
        }

        return true;
    }

    /**
     * Simula a redefinição da senha
     */
    private void simulatePasswordReset(String cpf, String novaSenha) {
        new Handler(Looper.getMainLooper()).postDelayed(() -> {
            // Simular sucesso na redefinição
            Toast.makeText(getContext(), "Senha redefinida com sucesso!", Toast.LENGTH_LONG).show();

            if (listener != null) {
                listener.onPasswordReset();
            }

        }, 2000); // 2 segundos de delay
    }

    @Override
    public void onDetach() {
        super.onDetach();
        listener = null;
    }
}