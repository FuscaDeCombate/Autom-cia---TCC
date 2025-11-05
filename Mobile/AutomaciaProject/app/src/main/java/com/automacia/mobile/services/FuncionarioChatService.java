package com.automacia.mobile.services;

import android.util.Log;

import com.automacia.mobile.models.FuncionarioChatDTO;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.Executor;
import java.util.concurrent.Executors;

public class FuncionarioChatService {

    private static final String TAG = "FuncionarioChatService";
    private final Executor executor;

    // Interface de callback para retornar resultados
    public interface FuncionarioCallback {
        void onSuccess(List<FuncionarioChatDTO> funcionarios);
        void onError(String errorMessage);
    }

    // Construtor
    public FuncionarioChatService() {
        this.executor = Executors.newSingleThreadExecutor();
    }

    /**
     * Busca a lista de funcionários disponíveis para chat com o paciente
     *
     * @param cpfPaciente CPF do paciente logado
     * @param callback Interface de callback para retornar os resultados
     */
    public void buscarFuncionariosParaChat(String cpfPaciente, FuncionarioCallback callback) {
        if (cpfPaciente == null || cpfPaciente.trim().isEmpty()) {
            Log.e(TAG, "CPF do paciente é nulo ou vazio");
            callback.onError("CPF do paciente inválido");
            return;
        }

        executor.execute(() -> {
            Connection connection = null;
            CallableStatement callableStatement = null;
            ResultSet resultSet = null;
            List<FuncionarioChatDTO> funcionarios = new ArrayList<>();

            try {
                Log.d(TAG, "Iniciando busca de funcionários para CPF: " + cpfPaciente);

                // Obtém conexão
                connection = DatabaseHelper.getConnection();

                if (connection == null) {
                    Log.e(TAG, "Falha ao obter conexão com banco de dados");
                    callback.onError("Erro de conexão com o banco de dados");
                    return;
                }

                Log.d(TAG, "Conexão estabelecida com sucesso");

                // Prepara chamada da procedure
                String sql = "{CALL Funcionarios_Paciente_Chat(?)}";
                callableStatement = connection.prepareCall(sql);
                callableStatement.setString(1, cpfPaciente);

                Log.d(TAG, "Executando procedure: Funcionarios_Paciente_Chat");

                // Executa procedure
                resultSet = callableStatement.executeQuery();

                int count = 0;
                // Processa resultados
                while (resultSet != null && resultSet.next()) {
                    try {
                        FuncionarioChatDTO funcionario = new FuncionarioChatDTO();

                        // Mapeia os campos do ResultSet para o DTO
                        funcionario.setFuncionarioRec(resultSet.getString("Funcionar_Rec"));
                        funcionario.setNomeFuncionario(resultSet.getString("Nome_Funcionario"));
                        funcionario.setTipoFuncionario(resultSet.getString("Tipo_Funcionario"));
                        funcionario.setHospital(resultSet.getString("Hospital"));
                        funcionario.setChatAberto(resultSet.getInt("ChatAberto") == 1);
                        funcionario.setAtivo(resultSet.getInt("Ativo") == 1);

                        funcionarios.add(funcionario);
                        count++;

                        Log.d(TAG, "Funcionário carregado: " + funcionario.getNomeFuncionario() +
                                " (" + funcionario.getTipoFuncionario() + ")");

                    } catch (SQLException e) {
                        Log.e(TAG, "Erro ao mapear funcionário do ResultSet: " + e.getMessage(), e);
                        // Continua processando os próximos registros
                    }
                }

                Log.d(TAG, "Total de funcionários carregados: " + count);

                // Verifica se encontrou resultados
                if (funcionarios.isEmpty()) {
                    Log.w(TAG, "Nenhum funcionário encontrado para o CPF: " + cpfPaciente);
                    callback.onError("Nenhum funcionário disponível no momento");
                } else {
                    Log.d(TAG, "Busca concluída com sucesso");
                    callback.onSuccess(funcionarios);
                }

            } catch (SQLException e) {
                Log.e(TAG, "Erro SQL ao buscar funcionários", e);
                Log.e(TAG, "SQLState: " + e.getSQLState());
                Log.e(TAG, "ErrorCode: " + e.getErrorCode());
                Log.e(TAG, "Message: " + e.getMessage());
                callback.onError("Erro ao buscar funcionários: " + e.getMessage());

            } catch (Exception e) {
                Log.e(TAG, "Erro inesperado ao buscar funcionários", e);
                callback.onError("Erro inesperado: " + e.getMessage());

            } finally {
                // Fecha recursos
                closeResources(resultSet, callableStatement, connection);
            }
        });
    }

    /**
     * Fecha os recursos do banco de dados de forma segura
     */
    private void closeResources(ResultSet resultSet, CallableStatement statement, Connection connection) {
        try {
            if (resultSet != null && !resultSet.isClosed()) {
                resultSet.close();
                Log.d(TAG, "ResultSet fechado");
            }
        } catch (SQLException e) {
            Log.e(TAG, "Erro ao fechar ResultSet: " + e.getMessage(), e);
        }

        try {
            if (statement != null && !statement.isClosed()) {
                statement.close();
                Log.d(TAG, "CallableStatement fechado");
            }
        } catch (SQLException e) {
            Log.e(TAG, "Erro ao fechar CallableStatement: " + e.getMessage(), e);
        }

        try {
            if (connection != null && !connection.isClosed()) {
                DatabaseHelper.closeConnection(connection);
            }
        } catch (SQLException e) {
            Log.e(TAG, "Erro ao verificar estado da conexão: " + e.getMessage(), e);
        }
    }
}