package com.automacia.mobile.dialogs;

import android.app.Dialog;
import android.content.Context;
import android.os.Bundle;
import android.view.View;
import android.view.Window;
import android.widget.TextView;

import com.automacia.mobile.R;
import com.google.android.material.button.MaterialButton;

/**
 * Dialog reutilizável para exibir erros de conexão com banco de dados
 *
 * Uso básico:
 * ConnectionErrorDialog dialog = new ConnectionErrorDialog(context);
 * dialog.setErrorMessage("Não foi possível conectar ao banco de dados");
 * dialog.setOnRetryListener(() -> {
 *     // Código para tentar reconectar
 * });
 * dialog.show();
 */
public class ConnectionErrorDialog extends Dialog {

    private TextView tvErrorTitle;
    private TextView tvErrorMessage;
    private TextView tvErrorDetails;
    private MaterialButton btnRetry;
    private MaterialButton btnCancel;

    private String errorTitle = "Erro de Conexão";
    private String errorMessage = "Não foi possível conectar ao banco de dados. Verifique sua conexão e tente novamente.";
    private String errorDetails = null;
    private boolean showTechnicalDetails = false;

    private OnRetryListener onRetryListener;
    private OnCancelListener onCancelDialogListener;

    public ConnectionErrorDialog(Context context ) {
        super(context, R.style.DialogTheme);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.dialog_connection_error);

        initViews();
        setupListeners();
        applyConfiguration();
    }

    private void initViews() {
        tvErrorTitle = findViewById(R.id.tvErrorTitle);
        tvErrorMessage = findViewById(R.id.tvErrorMessage);
        tvErrorDetails = findViewById(R.id.tvErrorDetails);
        btnRetry = findViewById(R.id.btnRetry);
        btnCancel = findViewById(R.id.btnCancel);
    }

    private void setupListeners() {
        btnRetry.setOnClickListener(v -> {
            if (onRetryListener != null) {
                onRetryListener.onRetry();
            }
            dismiss();
        });

        btnCancel.setOnClickListener(v -> {
            if (onCancelDialogListener != null) {
                onCancelDialogListener.onCancel();
            }
            dismiss();
        });
    }

    private void applyConfiguration() {
        tvErrorTitle.setText(errorTitle);
        tvErrorMessage.setText(errorMessage);

        if (showTechnicalDetails && errorDetails != null && !errorDetails.isEmpty()) {
            tvErrorDetails.setText(errorDetails);
            tvErrorDetails.setVisibility(View.VISIBLE);
        } else {
            tvErrorDetails.setVisibility(View.GONE);
        }
    }

    // Métodos de configuração (Builder Pattern)

    /**
     * Define o título do erro
     */
    public ConnectionErrorDialog setErrorTitle(String title) {
        this.errorTitle = title;
        if (tvErrorTitle != null) {
            tvErrorTitle.setText(title);
        }
        return this;
    }

    /**
     * Define a mensagem de erro principal
     */
    public ConnectionErrorDialog setErrorMessage(String message) {
        this.errorMessage = message;
        if (tvErrorMessage != null) {
            tvErrorMessage.setText(message);
        }
        return this;
    }

    /**
     * Define os detalhes técnicos do erro (stack trace, código de erro, etc)
     */
    public ConnectionErrorDialog setErrorDetails(String details) {
        this.errorDetails = details;
        this.showTechnicalDetails = true;
        if (tvErrorDetails != null) {
            tvErrorDetails.setText(details);
            tvErrorDetails.setVisibility(View.VISIBLE);
        }
        return this;
    }

    /**
     * Define se deve exibir os detalhes técnicos
     */
    public ConnectionErrorDialog showTechnicalDetails(boolean show) {
        this.showTechnicalDetails = show;
        if (tvErrorDetails != null) {
            tvErrorDetails.setVisibility(show && errorDetails != null ? View.VISIBLE : View.GONE);
        }
        return this;
    }

    /**
     * Define o listener para o botão "Tentar Novamente"
     */
    public ConnectionErrorDialog setOnRetryListener(OnRetryListener listener) {
        this.onRetryListener = listener;
        return this;
    }

    /**
     * Define o listener para o botão "Cancelar"
     */
    public ConnectionErrorDialog setOnCancelListener(OnCancelListener listener) {
        this.onCancelDialogListener = listener;
        return this;
    }

    /**
     * Oculta o botão cancelar (útil quando retry é obrigatório)
     */
    public ConnectionErrorDialog hideCancelButton() {
        if (btnCancel != null) {
            btnCancel.setVisibility(View.GONE);
        }
        return this;
    }

    /**
     * Configura o dialog com base em uma exceção
     */
    public ConnectionErrorDialog fromException(Exception e) {
        this.errorMessage = "Erro ao conectar: " + e.getMessage();
        this.errorDetails = getStackTraceString(e);
        return this;
    }

    /**
     * Cria uma mensagem de erro específica para diferentes tipos de erro de BD
     */
    public ConnectionErrorDialog setDatabaseErrorType(DatabaseErrorType errorType) {
        switch (errorType) {
            case CONNECTION_TIMEOUT:
                setErrorTitle("Tempo Esgotado");
                setErrorMessage("A conexão com o banco de dados demorou muito tempo. Verifique sua internet.");
                break;
            case AUTHENTICATION_FAILED:
                setErrorTitle("Falha na Autenticação");
                setErrorMessage("Não foi possível autenticar com o banco de dados. Verifique as credenciais.");
                break;
            case DATABASE_NOT_FOUND:
                setErrorTitle("Banco Não Encontrado");
                setErrorMessage("O banco de dados especificado não foi encontrado.");
                break;
            case QUERY_ERROR:
                setErrorTitle("Erro na Consulta");
                setErrorMessage("Ocorreu um erro ao executar a operação no banco de dados.");
                break;
            case NETWORK_ERROR:
                setErrorTitle("Erro de Rede");
                setErrorMessage("Não foi possível estabelecer conexão. Verifique sua internet.");
                break;
            default:
                setErrorTitle("Erro de Conexão");
                setErrorMessage("Ocorreu um erro ao conectar com o banco de dados.");
                break;
        }
        return this;
    }

    // Interfaces de callback

    public interface OnRetryListener {
        void onRetry();
    }

    public interface OnCancelListener {
        void onCancel();
    }

    // Enum para tipos de erro

    public enum DatabaseErrorType {
        CONNECTION_TIMEOUT,
        AUTHENTICATION_FAILED,
        DATABASE_NOT_FOUND,
        QUERY_ERROR,
        NETWORK_ERROR,
        UNKNOWN
    }

    // Método auxiliar para obter stack trace

    private String getStackTraceString(Exception e) {
        StringBuilder sb = new StringBuilder();
        sb.append(e.getClass().getName()).append(": ").append(e.getMessage()).append("\n");
        for (StackTraceElement element : e.getStackTrace()) {
            sb.append("  at ").append(element.toString()).append("\n");
            if (sb.length() > 500) { // Limita o tamanho
                sb.append("  ...");
                break;
            }
        }
        return sb.toString();
    }
}