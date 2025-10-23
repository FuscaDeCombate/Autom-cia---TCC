package com.automacia.mobile.services;

import android.os.StrictMode;
import android.util.Log;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Locale;

public class DatabaseHelper {

    private static final String TAG = "DatabaseHelper";

    // Configurações do banco
    private static final String SERVER_IP = "192.168.30.189";
    private static final String DATABASE_NAME = "Automacia";
    private static final String USERNAME = "android_user";
    private static final String PASSWORD = "SenhaForte123!";
    private static final int PORT = 1433;

    static {
        try {
            Class.forName("net.sourceforge.jtds.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            Log.e(TAG, "Erro ao carregar driver jTDS", e);
        }
    }

    public static Connection getConnection() throws SQLException {
        // Permitir operações de rede na thread principal (apenas para testes)
        StrictMode.ThreadPolicy policy = new StrictMode.ThreadPolicy.Builder()
                .permitAll()
                .build();
        StrictMode.setThreadPolicy(policy);

        try {
            // URL no formato jTDS com usuário, senha e criptografia
            String connectionUrl = String.format(
                    Locale.ROOT,
                    "jdbc:jtds:sqlserver://%s:%d;databaseName=%s;user=%s;password=%s;encrypt=true;trustServerCertificate=true",
                    SERVER_IP,
                    PORT,
                    DATABASE_NAME,
                    USERNAME,
                    PASSWORD
            );

            Log.d(TAG, "Tentando conectar com jTDS: " + connectionUrl);

            Connection connection = DriverManager.getConnection(connectionUrl);

            Log.d(TAG, "Conexão jTDS estabelecida com sucesso");
            return connection;

        } catch (SQLException e) {
            Log.e(TAG, "Erro ao conectar com o banco via jTDS", e);
            throw e;
        }
    }

    public static void closeConnection(Connection connection) {
        if (connection != null) {
            try {
                connection.close();
                Log.d(TAG, "Conexão jTDS fechada");
            } catch (SQLException e) {
                Log.e(TAG, "Erro ao fechar conexão jTDS", e);
            }
        }
    }

    /**
     * Testa a conexão com o banco executando uma query simples
     * Substitui o metodo isValid() que causa AbstractMethodError no Android
     */
    public static boolean testConnection() {
        Connection connection = null;
        PreparedStatement statement = null;
        ResultSet resultSet = null;

        try {
            connection = getConnection();
            if (connection == null || connection.isClosed()) {
                Log.d(TAG, "Conexão nula ou fechada");
                return false;
            }

            // Testa com uma query simples que funciona no SQL Server
            String testQuery = "SELECT 1 as test_result";
            statement = connection.prepareStatement(testQuery);
            resultSet = statement.executeQuery();

            boolean hasResult = resultSet.next();
            if (hasResult) {
                int result = resultSet.getInt("test_result");
                Log.d(TAG, "Teste de conexão bem-sucedido. Resultado: " + result);
                return true;
            }

            Log.d(TAG, "Query executada mas sem resultado");
            return false;

        } catch (SQLException e) {
            Log.e(TAG, "Teste de conexão via jTDS falhou - SQL Error: " + e.getMessage(), e);
            return false;
        } catch (Exception e) {
            Log.e(TAG, "Teste de conexão via jTDS falhou - Erro geral", e);
            return false;
        } finally {
            // Fecha recursos na ordem correta
            try {
                if (resultSet != null) {
                    resultSet.close();
                }
                if (statement != null) {
                    statement.close();
                }
            } catch (SQLException e) {
                Log.e(TAG, "Erro ao fechar recursos do teste", e);
            } finally {
                closeConnection(connection);
            }
        }
    }
}