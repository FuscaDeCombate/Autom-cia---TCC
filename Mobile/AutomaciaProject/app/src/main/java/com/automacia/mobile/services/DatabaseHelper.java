package com.automacia.mobile.services;

import android.os.StrictMode;
import android.util.Log;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Locale;

public class DatabaseHelper {

    private static final String TAG = "DatabaseHelper";

    // Configurações do banco
    private static final String SERVER_IP = "192.168.20.61";
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

    public static boolean testConnection() {
        try {
            Connection connection = getConnection();
            boolean isValid = connection != null && connection.isValid(5);
            closeConnection(connection);
            return isValid;
        } catch (SQLException e) {
            Log.e(TAG, "Teste de conexão via jTDS falhou", e);
            return false;
        }
    }
}
