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
                java.sql.Statement stmt = null;
                java.sql.ResultSet rs = null;

                try {
                    Log.d(TAG, "Testando conexão com banco de dados...");
                    connection = DatabaseHelper.getConnection();

                    if (connection == null) {
                        return new LoginResult(false,
                                "Falha ao estabelecer conexão com o servidor. Verifique se o servidor está acessível.",
                                null);
                    }

                    // REMOVIDO: connection.isValid() - não suportado pelo jTDS
                    // Em vez disso, testa com uma query simples

                    Log.d(TAG, "Conexão estabelecida, testando consulta...");

                    // Testar uma consulta simples
                    stmt = connection.createStatement();
                    stmt.setQueryTimeout(5); // 5 segundos de timeout
                    rs = stmt.executeQuery(
                            "SELECT COUNT(*) as total FROM Paciente WHERE Ativo = 1"
                    );

                    if (rs.next()) {
                        int total = rs.getInt("total");
                        Log.d(TAG, "Teste bem-sucedido! Total de pacientes ativos: " + total);
                        return new LoginResult(true,
                                "Conexão OK - " + total + " pacientes encontrados",
                                null);
                    }

                    return new LoginResult(false,
                            "Erro ao executar consulta de teste no banco de dados.",
                            null);

                } catch (SQLException e) {
                    Log.e(TAG, "Erro SQL no teste: " + e.getMessage(), e);
                    String errorMsg = interpretSQLError(e);
                    return new LoginResult(false, errorMsg, null);

                } catch (Exception e) {
                    Log.e(TAG, "Erro no teste: " + e.getMessage(), e);
                    return new LoginResult(false,
                            "Erro inesperado: " + e.getMessage(),
                            null);
                } finally {
                    // Fechar recursos na ordem correta
                    try {
                        if (rs != null) rs.close();
                    } catch (SQLException e) {
                        Log.e(TAG, "Erro ao fechar ResultSet", e);
                    }

                    try {
                        if (stmt != null) stmt.close();
                    } catch (SQLException e) {
                        Log.e(TAG, "Erro ao fechar Statement", e);
                    }

                    if (connection != null) {
                        DatabaseHelper.closeConnection(connection);
                    }
                }
            }

            @Override
            protected void onPostExecute(LoginResult result) {
                if (result.isSuccess()) {
                    callback.onSuccess(null);
                } else {
                    callback.onError(result.getMensagem());
                }
            }
        }.execute();
    }

    /**
     * Interpreta erros SQL para mensagens amigáveis
     */
    private static String interpretSQLError(SQLException e) {
        String errorMsg = e.getMessage().toLowerCase();
        int errorCode = e.getErrorCode();

        // Erros de autenticação
        if (errorCode == 18456 || errorMsg.contains("login failed")) {
            return "Falha na autenticação: Usuário ou senha incorretos no banco de dados.";
        }

        // Erros de conexão/rede
        if (errorMsg.contains("connection refused") ||
                errorMsg.contains("unable to connect") ||
                errorMsg.contains("i/o error")) {
            return "Não foi possível conectar ao servidor. Verifique:\n" +
                    "• Se o IP está correto (192.168.15.3)\n" +
                    "• Se o servidor está ligado\n" +
                    "• Se a porta 1433 está aberta";
        }

        // Timeout
        if (errorMsg.contains("timeout") || errorMsg.contains("timed out")) {
            return "Tempo de conexão esgotado. Verifique:\n" +
                    "• Sua conexão com a internet\n" +
                    "• Se está na mesma rede do servidor";
        }

        // Banco não encontrado
        if (errorMsg.contains("cannot open database") ||
                errorMsg.contains("database") && errorMsg.contains("not")) {
            return "Banco de dados 'Automacia' não encontrado no servidor.";
        }

        // Host não encontrado
        if (errorMsg.contains("unknown host") ||
                errorMsg.contains("no route to host")) {
            return "Servidor não encontrado. Verifique:\n" +
                    "• Se o IP 192.168.15.3 está correto\n" +
                    "• Se você está conectado à rede WiFi";
        }

        // SSL/TLS errors
        if (errorMsg.contains("ssl") || errorMsg.contains("certificate")) {
            return "Erro de certificado SSL. Verifique as configurações de segurança do banco.";
        }

        // Erro genérico
        return "Erro SQL (" + errorCode + "): " + e.getMessage();
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