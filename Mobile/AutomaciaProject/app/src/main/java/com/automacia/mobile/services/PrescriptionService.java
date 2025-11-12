package com.automacia.mobile.services;

import android.os.Handler;
import android.os.Looper;
import android.util.Log;

import com.automacia.mobile.models.PrescriptionDTO;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

public class PrescriptionService {
    private static final String TAG = "PrescriptionService";
    private final ExecutorService executorService;
    private final Handler mainHandler;

    public PrescriptionService() {
        this.executorService = Executors.newSingleThreadExecutor();
        this.mainHandler = new Handler(Looper.getMainLooper());
    }

    /**
     * Interface para callbacks de sucesso/erro
     */
    public interface PrescriptionCallback {
        void onSuccess(List<PrescriptionDTO> prescriptions);
        void onError(String errorMessage);
    }

    /**
     * Busca SIMPLES - Apenas dados necessários para o adpater simples (HomeFragment)
     * Campos retornados: ID_Receita, Medicamento, Funcionar_Nome, Data_Validade, Valido, Baixas, Limite_Baixas
     */
    public void fetchSimplePrescription(String cpf, PrescriptionCallback callback) {
        executorService.execute(() -> {
            Connection connection = null;
            CallableStatement updateStmt = null;
            CallableStatement selectStmt = null;
            ResultSet resultSet = null;
            List<PrescriptionDTO> prescriptions = new ArrayList<>();

            try {
                connection = DatabaseHelper.getConnection();

                if (connection == null || connection.isClosed()) {
                    notifyError(callback, "Falha ao conectar com o banco de dados");
                    return;
                }

                // 1. Executar procedure de atualização ANTES de buscar
                Log.d(TAG, "Executando Atualiza_Receita...");
                updateStmt = connection.prepareCall("{CALL Atualiza_Receita}");
                updateStmt.execute();
                Log.d(TAG, "Receitas atualizadas com sucesso");

                // 2. Buscar receitas do usuário
                Log.d(TAG, "Buscando receitas simples para CPF: " + cpf);
                selectStmt = connection.prepareCall("{CALL Ver_Receita(?)}");
                selectStmt.setString(1, cpf);

                resultSet = selectStmt.executeQuery();

                // Verificar se há resultados
                if (!resultSet.isBeforeFirst()) {
                    Log.d(TAG, "Nenhuma receita entrada para o CPF: " + cpf);
                    notifySuccess(callback, prescriptions); // Lista Vazia
                    return;
                }

                // 3. Processar apenas campos necessários para versão SIMPLES
                while (resultSet.next()) {
                    // VALIDAÇÃO: Verifica se é mensagem de erro ou dados reais
                    try {
                        // Tenta pegar uma coluna que só existe em receitas reais
                        int idReceita = resultSet.getInt("ID_Receita");

                        PrescriptionDTO dto = new PrescriptionDTO();
                        dto.setIdReceita(idReceita);
                        dto.setMedicamento(resultSet.getString("Medicamento"));
                        dto.setFuncionarioNome(resultSet.getString("Funcionar_Nome"));
                        dto.setDataValidade(resultSet.getDate("Data_Validade"));
                        dto.setValido(resultSet.getBoolean("Valido"));
                        dto.setBaixas(resultSet.getInt("Baixas"));
                        dto.setLimiteBaixas(resultSet.getInt("Limite_Baixas"));

                        prescriptions.add(dto);
                        Log.d(TAG, "Receita carregada (simples): " + dto.getMedicamento());

                    } catch (SQLException e) {
                        // Se falhou, é porque recebeu mensagem de texto, não dados
                        try {
                            String mensagem = resultSet.getString("Ver_Receita_Retorno");
                            Log.d(TAG, "Mensagem da procedure: " + mensagem);
                        } catch (SQLException ex) {
                            Log.e(TAG, "Erro ao processar resultado", ex);
                        }
                        break; // Sai do loop, não há dados para processar
                    }
                }

                Log.d(TAG, "Total de receitas carregadas (simples): " + prescriptions.size());
                notifySuccess(callback, prescriptions);
            } catch (SQLException e) {
                Log.e(TAG, "Erro SQL ao buscar receitas simples: " + e.getMessage(), e);
                Log.e(TAG, "SQL State: " + e.getSQLState());
                Log.e(TAG, "Error Code: " + e.getErrorCode());
                notifyError(callback, "Erro ao buscar receitas: " + e.getMessage());

            } catch (Exception e) {
                Log.e(TAG, "Erro geral ao buscar receitas simples", e);
                notifyError(callback, "Erro inesperado: " + e.getMessage());

            } finally {
                closeResources(resultSet, updateStmt, selectStmt, connection);
            }
        });
    }

    /**
     * Busca COMPLETA - Todos os dados da receita (para activity detalhada)
     * Retorna TODOS os campos da tabela Receita
     */
    public void fetchCompletePrescriptions(String cpf, PrescriptionCallback callback) {
        executorService.execute(() -> {
            Connection connection = null;
            CallableStatement updateStmt = null;
            CallableStatement selectStmt = null;
            ResultSet resultSet = null;
            List<PrescriptionDTO> prescriptions = new ArrayList<>();

            try {
                connection = DatabaseHelper.getConnection();

                if (connection == null || connection.isClosed()) {
                    notifyError(callback, "Falha ao conectar com o banco de dados");
                    return;
                }

                // 1. Executar procedure de atualização
                Log.d(TAG, "Executando Atualiza_Receita...");
                updateStmt = connection.prepareCall("{CALL Atualiza_Receita}");
                updateStmt.execute();
                Log.d(TAG, "Receitas atualizadas com sucesso");

                // 2. Buscar receitas do usuário
                Log.d(TAG, "Buscando receitas completas para CPF: " + cpf);
                selectStmt = connection.prepareCall("{CALL Ver_Receita(?)}");
                selectStmt.setString(1, cpf);

                resultSet = selectStmt.executeQuery();

                if (!resultSet.isBeforeFirst()) {
                    Log.d(TAG, "Nenhuma receita encontrada para o CPF: " + cpf);
                    notifySuccess(callback, prescriptions);
                    return;
                }

                // 3. Processar TODOS os campos para versão COMPLETA
                while (resultSet.next()) {
                    PrescriptionDTO dto = new PrescriptionDTO();

                    // TODOS os campos da tabela
                    dto.setIdReceita(resultSet.getInt("ID_Receita"));
                    dto.setDataReceita(resultSet.getTimestamp("Data_Receita"));
                    dto.setDataValidade(resultSet.getDate("Data_Validade"));
                    dto.setFuncionarioRec(resultSet.getInt("Funcionar_Rec"));
                    dto.setFuncionarioNome(resultSet.getString("Funcionar_Nome"));
                    dto.setPacienteF(resultSet.getString("Paciente_F"));
                    dto.setMedicamento(resultSet.getString("Medicamento"));
                    dto.setDetalhes(resultSet.getString("Detalhes"));
                    dto.setLimiteBaixas(resultSet.getInt("Limite_Baixas"));
                    dto.setValido(resultSet.getBoolean("Valido"));
                    dto.setBaixas(resultSet.getInt("Baixas"));

                    prescriptions.add(dto);

                    Log.d(TAG, "Receita carregada (completa): " + dto.getMedicamento() +
                            " - ID: " + dto.getIdReceita() +
                            " - Válida: " + dto.isValido() +
                            " - Detalhes: " + (dto.getDetalhes() != null ? "Sim" : "Não"));
                }

                Log.d(TAG, "Total de receitas carregadas (completas): " + prescriptions.size());
                notifySuccess(callback, prescriptions);

            } catch (SQLException e) {
                Log.e(TAG, "Erro SQL ao buscar receitas completas: " + e.getMessage(), e);
                Log.e(TAG, "SQL State: " + e.getSQLState());
                Log.e(TAG, "Error Code: " + e.getErrorCode());
                notifyError(callback, "Erro ao buscar receitas: " + e.getMessage());

            } catch (Exception e) {
                Log.e(TAG, "Erro geral ao buscar receitas completas", e);
                notifyError(callback, "Erro inesperado: " + e.getMessage());

            } finally {
                closeResources(resultSet, updateStmt, selectStmt, connection);
            }
        });
    }

    /**
     * Busca uma receita específica por ID (versão completa)
     */
    public void fetchPrescriptionById(int idReceita, PrescriptionCallback callback) {
        executorService.execute(() -> {
            Connection connection = null;
            CallableStatement selectStmt = null;
            ResultSet resultSet = null;
            List<PrescriptionDTO> prescriptions = new ArrayList<>();

            try {
                connection = DatabaseHelper.getConnection();

                if (connection == null || connection.isClosed()) {
                    notifyError(callback, "Falha ao conectar com o banco de dados");
                    return;
                }

                Log.d(TAG, "Buscando receita por ID: " + idReceita);

                // Query direta para buscar por ID
                String query = "SELECT * FROM Receita WHERE ID_Receita = ?";
                selectStmt = connection.prepareCall(query);
                selectStmt.setInt(1, idReceita);

                resultSet = selectStmt.executeQuery();

                if (resultSet.next()) {
                    PrescriptionDTO dto = new PrescriptionDTO();

                    dto.setIdReceita(resultSet.getInt("ID_Receita"));
                    dto.setDataReceita(resultSet.getTimestamp("Data_Receita"));
                    dto.setDataValidade(resultSet.getDate("Data_Validade"));
                    dto.setFuncionarioRec(resultSet.getInt("Funcionar_Rec"));
                    dto.setFuncionarioNome(resultSet.getString("Funcionar_Nome"));
                    dto.setPacienteF(resultSet.getString("Paciente_F"));
                    dto.setMedicamento(resultSet.getString("Medicamento"));
                    dto.setDetalhes(resultSet.getString("Detalhes"));
                    dto.setLimiteBaixas(resultSet.getInt("Limite_Baixas"));
                    dto.setValido(resultSet.getBoolean("Valido"));
                    dto.setBaixas(resultSet.getInt("Baixas"));

                    prescriptions.add(dto);
                    Log.d(TAG, "Receita encontrada: " + dto.getMedicamento());
                } else {
                    Log.d(TAG, "Nenhuma receita encontrada com ID: " + idReceita);
                }

                notifySuccess(callback, prescriptions);

            } catch (SQLException e) {
                Log.e(TAG, "Erro SQL ao buscar receita por ID: " + e.getMessage(), e);
                notifyError(callback, "Erro ao buscar receita: " + e.getMessage());

            } catch (Exception e) {
                Log.e(TAG, "Erro geral ao buscar receita por ID", e);
                notifyError(callback, "Erro inesperado: " + e.getMessage());

            } finally {
                closeResources(resultSet, null, selectStmt, connection);
            }
        });
    }

    /**
     * Notifica sucesso na thread principal
     */
    private void notifySuccess(PrescriptionCallback callback, List<PrescriptionDTO> prescriptions) {
        mainHandler.post(() -> callback.onSuccess(prescriptions));
    }

    /**
     * Notifica erro na thread principal
     */
    private void notifyError(PrescriptionCallback callback, String errorMessage) {
        mainHandler.post(() -> callback.onError(errorMessage));
    }

    /**
     * Fecha todos os recursos do banco de dados
     */
    private void closeResources(ResultSet resultSet, CallableStatement stmt1,
                                CallableStatement stmt2, Connection connection) {
        try {
            if (resultSet != null && !resultSet.isClosed()) {
                resultSet.close();
            }
        } catch (SQLException e) {
            Log.e(TAG, "Erro ao fechar ResultSet", e);
        }

        try {
            if (stmt1 != null && !stmt1.isClosed()) {
                stmt1.close();
            }
        } catch (SQLException e) {
            Log.e(TAG, "Erro ao fechar Statement 1", e);
        }

        try {
            if (stmt2 != null && !stmt2.isClosed()) {
                stmt2.close();
            }
        } catch (SQLException e) {
            Log.e(TAG, "Erro ao fechar Statement 2", e);
        }

        DatabaseHelper.closeConnection(connection);
    }

    /**
     * Encerra o ExecutorService
     * Chame este metodo qunado não precisar mais do serviço
     */
    public void shutdown() {
        if (executorService != null && !executorService.isShutdown()) {
            executorService.shutdown();
            Log.d(TAG, "PrescriptionService encerrado");
        }
    }
}
