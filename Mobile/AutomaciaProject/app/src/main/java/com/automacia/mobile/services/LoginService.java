package com.automacia.mobile.services;

import android.os.AsyncTask;
import android.util.Log;

import com.automacia.mobile.models.UsuarioDTO;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;

/**
 * Serviço responsável pela autenticação de usuários
 */
public class LoginService {

    private static final String TAG = "LoginService";

    /**
     * Testa se a conexão e permissões estão funcionando
     */
    public static void testarConexaoAsync(LoginCallback callback) {
        new AsyncTask<Void, Void, LoginResult>() {
            @Override
            protected LoginResult doInBackground(Void... voids) {
                Connection connection = null;
                try {
                    Log.d(TAG, "Testando conexão com banco de dados...");
                    connection = DatabaseHelper.getConnection();

                    if (connection == null) {
                        return new LoginResult(false, "Falha na conexão", null);
                    }

                    if (!connection.isValid(5)) {
                        return new LoginResult(false, "Conexão inválida", null);
                    }

                    Log.d(TAG, "Conexão estabelecida com sucesso");

                    // Testar uma consulta simples
                    java.sql.Statement stmt = connection.createStatement();
                    java.sql.ResultSet rs = stmt.executeQuery("SELECT COUNT(*) as total FROM Paciente WHERE Ativo = 1");

                    if (rs.next()) {
                        int total = rs.getInt("total");
                        Log.d(TAG, "Total de pacientes ativos: " + total);
                        rs.close();
                        stmt.close();
                        return new LoginResult(true, "Conexão OK - " + total + " pacientes encontrados", null);
                    }

                    rs.close();
                    stmt.close();
                    return new LoginResult(false, "Erro na consulta de teste", null);

                } catch (SQLException e) {
                    Log.e(TAG, "Erro SQL no teste: " + e.getMessage(), e);
                    return new LoginResult(false, "Erro SQL: " + e.getMessage(), null);
                } catch (Exception e) {
                    Log.e(TAG, "Erro no teste: " + e.getMessage(), e);
                    return new LoginResult(false, "Erro: " + e.getMessage(), null);
                } finally {
                    if (connection != null) {
                        DatabaseHelper.closeConnection(connection);
                    }
                }
            }

            @Override
            protected void onPostExecute(LoginResult result) {
                if (result.isSuccess()) {
                    callback.onSuccess(null); // Apenas para indicar sucesso
                } else {
                    callback.onError(result.getMensagem());
                }
            }
        }.execute();
    }

    /**
     * Interface para callback do resultado do login
     */
    public interface LoginCallback {
        void onSuccess(UsuarioDTO usuario);
        void onError(String mensagem);
    }

    /**
     * Realiza login assíncrono do usuário
     */
    public static void loginAsync(String cpf, String senha, LoginCallback callback) {
        new LoginTask(callback).execute(cpf, senha);
    }

    /**
     * AsyncTask para realizar login em background
     */
    private static class LoginTask extends AsyncTask<String, Void, LoginResult> {

        private final LoginCallback callback;

        public LoginTask(LoginCallback callback) {
            this.callback = callback;
        }

        @Override
        protected LoginResult doInBackground(String... params) {
            String cpf = params[0];
            String senha = params[1];

            try {
                return performLogin(cpf, senha);
            } catch (Exception e) {
                Log.e(TAG, "Erro durante login", e);
                return new LoginResult(false, "Erro interno do sistema", null);
            }
        }

        @Override
        protected void onPostExecute(LoginResult result) {
            if (result.isSuccess()) {
                callback.onSuccess(result.getUsuario());
            } else {
                callback.onError(result.getMensagem());
            }
        }
    }

    /**
     * Realiza o login usando a stored procedure
     */
    private static LoginResult performLogin(String cpf, String senha) {
        Connection connection = null;
        CallableStatement statement = null;
        ResultSet resultSet = null;

        try {
            // Conectar ao banco
            connection = DatabaseHelper.getConnection();

            if (connection == null) {
                return new LoginResult(false, "Erro de conexão com o servidor", null);
            }
            /*
            // Hash da senha usando MD5 (como esperado pelo banco)
            String senhaHash = generateMD5Hash(senha);
            if (senhaHash == null) {
                return new LoginResult(false, "Erro ao processar senha", null);
            }

             */

            // Chamar stored procedure
            String sql = "{call Login_Paciente(?, ?)}";
            statement = connection.prepareCall(sql);
            statement.setString(1, cpf);
            statement.setString(2, senha);

            Log.d(TAG, "Executando login para CPF: " + cpf);

            // Executar procedure
            boolean hasResultSet = statement.execute();

            if (hasResultSet) {
                resultSet = statement.getResultSet();

                if (resultSet.next()) {
                    // Verificar se é uma mensagem de erro
                    try {
                        String loginRetorno = resultSet.getString("Login_Paciente_Retorno");
                        if (loginRetorno != null) {
                            // É uma mensagem de erro
                            Log.w(TAG, "Login falhou: " + loginRetorno);
                            return new LoginResult(false, loginRetorno, null);
                        }
                    } catch (SQLException e) {
                        // Coluna não existe, significa que é um resultado válido
                        // Continua processamento normal
                    }

                    // Login bem-sucedido - construir UsuarioDTO
                    UsuarioDTO usuario = buildUsuarioFromResultSet(resultSet);
                    Log.i(TAG, "Login bem-sucedido para: " + usuario.getNomeExibicao());
                    return new LoginResult(true, "Login realizado com sucesso", usuario);
                } else {
                    return new LoginResult(false, "Credenciais inválidas", null);
                }
            } else {
                return new LoginResult(false, "Erro na consulta ao banco", null);
            }

        } catch (SQLException e) {
            Log.e(TAG, "Erro SQL durante login", e);
            return new LoginResult(false, "Erro de comunicação com o servidor", null);
        } catch (Exception e) {
            Log.e(TAG, "Erro inesperado durante login", e);
            return new LoginResult(false, "Erro interno do sistema", null);
        } finally {
            // Fechar recursos
            try {
                if (resultSet != null) resultSet.close();
                if (statement != null) statement.close();
                if (connection != null) DatabaseHelper.closeConnection(connection);
            } catch (SQLException e) {
                Log.e(TAG, "Erro ao fechar recursos", e);
            }
        }
    }

    /**
     * Constrói UsuarioDTO a partir do ResultSet
     */
    private static UsuarioDTO buildUsuarioFromResultSet(ResultSet rs) throws SQLException {
        UsuarioDTO usuario = new UsuarioDTO();

        usuario.setCpf(rs.getString("Paciente_F"));
        usuario.setNome(rs.getString("Nome_Paciente"));
        usuario.setNomeSocial(rs.getString("Nome_Social"));
        usuario.setEmail(rs.getString("Email"));
        usuario.setTelefone(rs.getString("Fone"));
        usuario.setDataCriacao(rs.getTimestamp("Data_Criacao"));
        usuario.setAtivo(rs.getBoolean("Ativo"));

        return usuario;
    }

    /**
     * Classe para encapsular resultado do login
     */
    private static class LoginResult {
        private final boolean success;
        private final String mensagem;
        private final UsuarioDTO usuario;

        public LoginResult(boolean success, String mensagem, UsuarioDTO usuario) {
            this.success = success;
            this.mensagem = mensagem;
            this.usuario = usuario;
        }

        public boolean isSuccess() { return success; }
        public String getMensagem() { return mensagem; }
        public UsuarioDTO getUsuario() { return usuario; }
    }
}