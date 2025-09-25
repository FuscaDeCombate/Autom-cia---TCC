package com.automacia.mobile.fragments;

import android.content.Context;
import android.os.AsyncTask;
import android.os.Bundle;
import android.text.Editable;
import android.text.TextWatcher;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;

import com.automacia.mobile.R;
import com.automacia.mobile.services.DatabaseHelper;
import com.automacia.mobile.utils.Utils;
import com.google.android.material.button.MaterialButton;
import com.google.android.material.textfield.TextInputEditText;
import com.google.android.material.textfield.TextInputLayout;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

/**
 * Fragment responsável por redefinir a senha
 * Permite ao usuário inserir uma nova senha após verificação do código
 */
public class ResetPasswordFragment extends Fragment {

    // Constantes
    private static final String TAG = "ResetPasswordFragment";
    private static final String ARG_EMAIL = "email";
    private static final int PASSWORD_RESET_DELAY_MS = 2000;
    private static final String ERROR_GENERIC = "Erro interno. Tente novamente.";
    private static final String ERROR_INVALID_CPF = "CPF Inválido";
    private static final String ERROR_INVALID_PASSWORD = "Senha Inválida";
    private static final String ERROR_INVALID_INFO = "Informações Inválidas";
    private static final String SUCCESS_MESSAGE = "Senha alterada com sucesso";

    // Views
    private TextInputEditText editNovaSenha, editConfirmarSenha;
    private TextInputLayout layoutNovaSenha, layoutConfirmarSenha;
    private MaterialButton btnRedefinirSenha;
    private TextView txtDescricao;

    // Listener para comunicação com a Activity
    private OnPasswordResetListener listener;

    // Dados
    private String email;

    // Validação
    private boolean isNovaSenhaValid = false;
    private boolean isConfirmacaoValid = false;
    private boolean isResetting = false;

    /**
     * Interface para comunicação com a Activity
     */
    public interface OnPasswordResetListener {
        void onPasswordReset();
    }

    /**
     * Método factory para criar instância do fragment
     */
    public static ResetPasswordFragment newInstance(String email) {
        ResetPasswordFragment fragment = new ResetPasswordFragment();
        Bundle args = new Bundle();
        args.putString(ARG_EMAIL, email);
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
            email = getArguments().getString(ARG_EMAIL);
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
        setupAccessibility();
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
     * Configura acessibilidade
     */
    private void setupAccessibility() {
        editNovaSenha.setContentDescription("Nova senha - digite sua nova senha");
        editConfirmarSenha.setContentDescription("Confirmar senha - digite novamente sua nova senha");
        btnRedefinirSenha.setContentDescription("Redefinir senha");
        txtDescricao.setContentDescription("Instruções para redefinição de senha");
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
        boolean isEnabled = isNovaSenhaValid && isConfirmacaoValid && !isResetting;
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

        if (isResetting) {
            return; // Evita múltiplas execuções
        }

        String novaSenha = editNovaSenha.getText().toString();

        // Mostrar loading
        isResetting = true;
        btnRedefinirSenha.setEnabled(false);
        btnRedefinirSenha.setText("Redefinindo...");

        // Executar redefinição de senha no banco
        new ResetPasswordTask().execute(email, novaSenha);
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
     * AsyncTask para buscar CPF pelo email e alterar senha
     */
    private class ResetPasswordTask extends AsyncTask<String, Void, String> {

        @Override
        protected String doInBackground(String... params) {
            String emailParam = params[0];
            String novaSenha = params[1];

            Connection connection = null;
            PreparedStatement stmtBuscarCpf = null;
            PreparedStatement stmtAlterarSenha = null;
            ResultSet resultSet = null;

            try {
                // Conectar ao banco
                connection = DatabaseHelper.getConnection();
                if (connection == null) {
                    return ERROR_GENERIC;
                }

                // 1. Buscar CPF pelo email
                String queryBuscarCpf = "SELECT Paciente_F FROM Paciente WHERE Email = ? AND Ativo = 1";
                stmtBuscarCpf = connection.prepareStatement(queryBuscarCpf);
                stmtBuscarCpf.setString(1, emailParam);
                resultSet = stmtBuscarCpf.executeQuery();

                String cpf = null;
                if (resultSet.next()) {
                    cpf = resultSet.getString("Paciente_F");
                }

                if (cpf == null) {
                    return "Email não encontrado";
                }

                // Fechar resources da primeira query
                resultSet.close();
                stmtBuscarCpf.close();

                // 2. Executar procedure de alteração de senha
                String callProcedure = "{CALL Alt_Senha_P(?, ?)}";
                stmtAlterarSenha = connection.prepareCall(callProcedure);
                stmtAlterarSenha.setString(1, cpf);
                stmtAlterarSenha.setString(2, novaSenha);

                ResultSet procedureResult = stmtAlterarSenha.executeQuery();

                String resultado = ERROR_GENERIC;
                if (procedureResult.next()) {
                    resultado = procedureResult.getString("Alt_Senha_Retorno");
                }

                procedureResult.close();
                return resultado;

            } catch (SQLException e) {
                Log.e(TAG, "Erro SQL ao redefinir senha", e);
                return ERROR_GENERIC;
            } catch (Exception e) {
                Log.e(TAG, "Erro geral ao redefinir senha", e);
                return ERROR_GENERIC;
            } finally {
                // Limpar resources
                try {
                    if (resultSet != null) resultSet.close();
                    if (stmtBuscarCpf != null) stmtBuscarCpf.close();
                    if (stmtAlterarSenha != null) stmtAlterarSenha.close();
                } catch (SQLException e) {
                    Log.e(TAG, "Erro ao fechar resources", e);
                }
                DatabaseHelper.closeConnection(connection);
            }
        }

        @Override
        protected void onPostExecute(String resultado) {
            isResetting = false;
            btnRedefinirSenha.setText("Redefinir Senha");
            updateButtonState();

            if (getContext() == null) return;

            // Processar resultado da procedure
            if (SUCCESS_MESSAGE.equals(resultado)) {
                Toast.makeText(getContext(), "Senha redefinida com sucesso!", Toast.LENGTH_LONG).show();

                if (listener != null) {
                    listener.onPasswordReset();
                }
            } else {
                // Mostrar erro específico
                String mensagemErro;
                switch (resultado) {
                    case ERROR_INVALID_CPF:
                        mensagemErro = "Email não encontrado em nossa base de dados";
                        break;
                    case ERROR_INVALID_PASSWORD:
                        mensagemErro = "A senha deve ter pelo menos 6 caracteres";
                        break;
                    case ERROR_INVALID_INFO:
                        mensagemErro = "Dados inválidos. Tente novamente";
                        break;
                    case "Email não encontrado":
                        mensagemErro = "Email não encontrado. Verifique se está correto";
                        break;
                    default:
                        mensagemErro = "Erro ao redefinir senha. Tente novamente";
                        break;
                }

                Toast.makeText(getContext(), mensagemErro, Toast.LENGTH_LONG).show();
                Log.e(TAG, "Erro na redefinição: " + resultado);
            }
        }
    }

    @Override
    public void onDetach() {
        super.onDetach();
        listener = null;
    }
}