package com.automacia.mobile.services;

import android.os.Handler;
import android.os.Looper;
import android.util.Log;

import com.automacia.mobile.models.UsuarioDTO;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

/**
 * Service responsável pelas operações de cadastro de usuários
 * Implementa operações assíncronas para não bloquear a UI
 * Utiliza PreparedStatement para evitar SQL Injection
 * Integrado com EmailService para envio de confirmações
 */
public class RegisterService {

    private static final String TAG = "RegisterService";
    private final ExecutorService executor;
    private final Handler mainHandler;
    private final EmailService emailService;

    public RegisterService() {
        executor = Executors.newSingleThreadExecutor();
        mainHandler = new Handler(Looper.getMainLooper());
        emailService = new EmailService();
    }

    /**
     * Interface para callback do resultado do cadastro
     */
    public interface RegisterCallback {
        void onSuccess(String message);
        void onError(String error);
        void onLoading(boolean isLoading);
    }

    /**
     * Interface para callback de verificação de existência / status simples
     */
    public interface CheckExistenceCallback {
        void onResult(boolean ok, String field);
        void onError(String error);
    }

    /**
     * Registra um novo usuário usando PreparedStatement para evitar SQL Injection
     * Integrado com EmailService para envio automático de confirmação
     * @param usuario Dados do usuário a ser cadastrado
     * @param callback Callback para retorno do resultado
     */
    public void registrarUsuario(UsuarioDTO usuario, RegisterCallback callback) {
        // Indica início do loading
        mainHandler.post(() -> callback.onLoading(true));

        executor.execute(() -> {
            Connection connection = null;
            PreparedStatement preparedStatement = null;
            ResultSet resultSet = null;

            try {
                // Obtém conexão com o banco
                connection = DatabaseHelper.getConnection();

                // Query SQL usando PreparedStatement para evitar SQL Injection
                String sql = "EXEC Registra_Paciente ?, ?, ?, ?, ?, ?";
                preparedStatement = connection.prepareStatement(sql);

                // Define os parâmetros de forma segura
                preparedStatement.setString(1, usuario.getCpf());
                preparedStatement.setString(2, usuario.getSenha());
                preparedStatement.setString(3, usuario.getEmail());
                preparedStatement.setString(4, usuario.getNome());
                preparedStatement.setString(5, usuario.getNomeSocial() != null ? usuario.getNomeSocial() : "");
                preparedStatement.setString(6, usuario.getTelefone());

                Log.d(TAG, "Executando procedure de cadastro para CPF: " + usuario.getCpf());

                // Executa a query
                resultSet = preparedStatement.executeQuery();

                // Verifica se há resultado e processa
                if (resultSet != null && resultSet.next()) {
                    String resultado = resultSet.getString("Registra_Paciente_Retorno");
                    Log.d(TAG, "Resultado da procedure: " + resultado);

                    if ("Registro Concluido".equalsIgnoreCase(resultado)) {
                        // Sucesso no cadastro - envia email de confirmação
                        enviarEmailConfirmacao(usuario.getNome(), usuario.getEmail(), callback, usuario);
                    } else {
                        // Erro retornado pela procedure
                        String errorMessage = mapearMensagemErro(resultado);
                        mainHandler.post(() -> {
                            callback.onLoading(false);
                            callback.onError(errorMessage);
                        });
                    }
                } else {
                    // Não há resultado - cadastro executado mas sem retorno
                    Log.w(TAG, "Procedure executada mas sem resultado. Tentando enviar email mesmo assim.");

                    // Como a procedure pode ter executado com sucesso mesmo sem retorno,
                    // tentamos enviar o email e considerar sucesso
                    enviarEmailConfirmacao(usuario.getNome(), usuario.getEmail(), callback, usuario);
                }

            } catch (SQLException e) {
                Log.e(TAG, "Erro SQL durante cadastro", e);
                mainHandler.post(() -> {
                    callback.onLoading(false);
                    String errorMessage = mapearErroSQL(e);
                    callback.onError(errorMessage);
                });
            } catch (Exception e) {
                Log.e(TAG, "Erro geral durante cadastro", e);
                mainHandler.post(() -> {
                    callback.onLoading(false);
                    callback.onError("Erro de conexão. Verifique sua internet e tente novamente.");
                });
            } finally {
                // Fecha recursos de forma segura
                closeResources(resultSet, preparedStatement, connection);
            }
        });
    }

    /**
     * Envia email de confirmação após cadastro bem-sucedido
     * @param nome Nome do usuário
     * @param email Email do usuário
     * @param callback Callback original do registro
     * @param usuario Dados do usuário para limpeza posterior
     */
    private void enviarEmailConfirmacao(String nome, String email, RegisterCallback callback, UsuarioDTO usuario) {
        emailService.enviarEmailConfirmacao(nome, email, new EmailService.EmailCallback() {
            @Override
            public void onSuccess() {
                // Email enviado com sucesso
                mainHandler.post(() -> {
                    callback.onLoading(false);
                    // Limpa dados sensíveis após sucesso completo
                    usuario.clearSensitiveData();
                    callback.onSuccess("Cadastro realizado com sucesso! Verifique seu email para confirmar.");
                });
            }

            @Override
            public void onError(String error) {
                // Erro no envio do email, mas cadastro foi realizado
                Log.w(TAG, "Cadastro realizado mas falha no envio de email: " + error);
                mainHandler.post(() -> {
                    callback.onLoading(false);
                    // Limpa dados sensíveis mesmo com erro no email
                    usuario.clearSensitiveData();
                    callback.onSuccess("Cadastro realizado com sucesso! Houve um problema no envio do email de confirmação, mas você já pode fazer login.");
                });
            }
        });
    }

    /**
     * Verifica se um CPF já existe no sistema
     * @param cpf CPF a ser verificado
     * @param callback Callback para retorno do resultado
     */
    public void verificarCpfExistente(String cpf, CheckExistenceCallback callback) {
        executor.execute(() -> {
            Connection connection = null;
            PreparedStatement preparedStatement = null;
            ResultSet resultSet = null;

            try {
                connection = DatabaseHelper.getConnection();
                String sql = "SELECT COUNT(*) as total FROM Pacientes WHERE cpf = ?";
                preparedStatement = connection.prepareStatement(sql);
                preparedStatement.setString(1, cpf);

                resultSet = preparedStatement.executeQuery();

                if (resultSet.next()) {
                    int count = resultSet.getInt("total");
                    boolean existe = count > 0;

                    mainHandler.post(() -> callback.onResult(existe, "CPF"));
                } else {
                    mainHandler.post(() -> callback.onError("Erro ao verificar CPF"));
                }

            } catch (Exception e) {
                Log.e(TAG, "Erro ao verificar CPF existente", e);
                mainHandler.post(() -> callback.onError("Erro ao verificar CPF: " + e.getMessage()));
            } finally {
                closeResources(resultSet, preparedStatement, connection);
            }
        });
    }

    /**
     * Verifica se um email já existe no sistema
     * @param email Email a ser verificado
     * @param callback Callback para retorno do resultado
     */
    public void verificarEmailExistente(String email, CheckExistenceCallback callback) {
        executor.execute(() -> {
            Connection connection = null;
            PreparedStatement preparedStatement = null;
            ResultSet resultSet = null;

            try {
                connection = DatabaseHelper.getConnection();
                String sql = "SELECT COUNT(*) as total FROM Pacientes WHERE email = ?";
                preparedStatement = connection.prepareStatement(sql);
                preparedStatement.setString(1, email);

                resultSet = preparedStatement.executeQuery();

                if (resultSet.next()) {
                    int count = resultSet.getInt("total");
                    boolean existe = count > 0;

                    mainHandler.post(() -> callback.onResult(existe, "Email"));
                } else {
                    mainHandler.post(() -> callback.onError("Erro ao verificar email"));
                }

            } catch (Exception e) {
                Log.e(TAG, "Erro ao verificar email existente", e);
                mainHandler.post(() -> callback.onError("Erro ao verificar email: " + e.getMessage()));
            } finally {
                closeResources(resultSet, preparedStatement, connection);
            }
        });
    }

    /**
     * Testa a conexão com o banco de dados
     * @param callback Callback para retorno do resultado
     */
    public void testarConexao(CheckExistenceCallback callback) {
        executor.execute(() -> {
            try {
                boolean isConnected = DatabaseHelper.testConnection();
                mainHandler.post(() -> {
                    if (isConnected) {
                        callback.onResult(true, "Conexão");
                    } else {
                        callback.onError("Falha na conexão com o servidor");
                    }
                });
            } catch (Exception e) {
                Log.e(TAG, "Erro ao testar conexão", e);
                mainHandler.post(() -> callback.onError("Erro ao testar conexão: " + e.getMessage()));
            }
        });
    }

    /**
     * Fecha recursos de banco de dados de forma segura
     * @param resultSet ResultSet para fechar
     * @param statement PreparedStatement para fechar
     * @param connection Connection para fechar
     */
    private void closeResources(ResultSet resultSet, PreparedStatement statement, Connection connection) {
        try {
            if (resultSet != null) resultSet.close();
            if (statement != null) statement.close();
            DatabaseHelper.closeConnection(connection);
        } catch (SQLException e) {
            Log.e(TAG, "Erro ao fechar recursos", e);
        }
    }

    /**
     * Mapeia mensagens de erro da procedure para mensagens mais amigáveis
     * @param mensagemProcedure Mensagem retornada pela procedure
     * @return Mensagem amigável para o usuário
     */
    private String mapearMensagemErro(String mensagemProcedure) {
        if (mensagemProcedure == null) return "Erro desconhecido";

        switch (mensagemProcedure) {
            case "CPF já cadastrado":
                return "Este CPF já está cadastrado no sistema";

            case "Digite algo":
                return "Por favor, preencha todos os campos obrigatórios";

            case "CPF Inválido":
                return "CPF informado é inválido";

            case "Email Inválido":
                return "Email informado é inválido";

            case "Senha Inválida":
                return "A senha deve ter pelo menos 6 caracteres";

            case "Informações inválidas":
                return "Dados informados são inválidos. Verifique e tente novamente";

            default:
                return "Erro durante o cadastro: " + mensagemProcedure;
        }
    }

    /**
     * Mapeia erros SQL para mensagens mais amigáveis
     * @param e Exceção SQL
     * @return Mensagem amigável para o usuário
     */
    private String mapearErroSQL(SQLException e) {
        int errorCode = e.getErrorCode();

        // Códigos de erro específicos do SQL Server
        switch (errorCode) {
            case 2: // Cannot open database
            case 4060: // Invalid database name
                return "Erro de conexão com o banco de dados";

            case 18456: // Login failed
                return "Erro de autenticação no servidor";

            case 2547:
            case 2601: // Duplicate key
                return "CPF ou email já cadastrado no sistema";

            case 8152: // String or binary data would be truncated
                return "Dados muito longos para os campos";

            case -2: // Timeout
                return "Tempo limite de conexão excedido. Tente novamente";

            default:
                String msg = e.getMessage() != null ? e.getMessage().toLowerCase() : "";
                if (msg.contains("timeout")) {
                    return "Conexão lenta. Tente novamente";
                } else if (msg.contains("connection")) {
                    return "Problema de conexão. Verifique sua internet";
                } else {
                    return "Erro no servidor. Tente novamente em alguns minutos";
                }
        }
    }

    /**
     * Libera recursos do service
     * Deve ser chamado quando não precisar mais do service
     */
    public void shutdown() {
        if (executor != null && !executor.isShutdown()) {
            executor.shutdown();
        }
        if (emailService != null) {
            emailService.shutdown();
        }
    }
}