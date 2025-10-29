package com.automacia.mobile.services;

import android.util.Log;

import com.automacia.mobile.models.HistoricoMedicoDTO;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;

/**
 * Service para gerenciar operações de histórico médico
 */
public class MedicalHistoryService {

    private static final String TAG = "MedicalHistoryService";

    /**
     * Busca o histórico médico de um paciente pelo CPF
     * Retorna apenas o primeiro registro (mais recente)
     *
     * @param cpf CPF do paciente
     * @return HistoricoMedicoDTO ou null se não encontrado
     */
    public HistoricoMedicoDTO buscarHistoricoPorCPF(String cpf) {
        Connection connection = null;
        CallableStatement statement = null;
        ResultSet resultSet = null;

        Log.d(TAG, "==========================================");
        Log.d(TAG, "Iniciando busca de histórico médico");
        Log.d(TAG, "CPF: " + cpf);

        try {
            connection = DatabaseHelper.getConnection();
            Log.d(TAG, "Conexão estabelecida com sucesso");

            // Chama a stored procedure Ver_Historico
            String sql = "{CALL Ver_Historico(?)}";
            statement = connection.prepareCall(sql);
            statement.setString(1, cpf);

            Log.d(TAG, "Executando procedure: Ver_Historico");
            Log.d(TAG, "Parâmetro CPF: " + cpf);

            resultSet = statement.executeQuery();

            // Verifica se há resultados
            if (resultSet.next()) {
                // Verifica se retornou mensagem de erro
                try {
                    String retorno = resultSet.getString("Retorno_Ver_Histórico");
                    if (retorno != null) {
                        Log.w(TAG, "Mensagem do banco: " + retorno);
                        return null;
                    }
                } catch (SQLException e) {
                    // Coluna não existe, significa que retornou dados válidos
                }

                // Extrai os dados do histórico
                int idHistorico = resultSet.getInt("ID_Historico");
                byte[] registroMedico = resultSet.getBytes("Registro_Medico");
                java.sql.Timestamp dataRegistro = resultSet.getTimestamp("Data_Registro");

                Log.d(TAG, "Histórico encontrado!");
                Log.d(TAG, "ID: " + idHistorico);
                Log.d(TAG, "Data Registro: " + dataRegistro);
                Log.d(TAG, "Tamanho do PDF: " + (registroMedico != null ? registroMedico.length : 0) + " bytes");

                if (registroMedico == null || registroMedico.length == 0) {
                    Log.w(TAG, "Registro médico está vazio ou nulo");
                    return null;
                }

                HistoricoMedicoDTO historico = new HistoricoMedicoDTO(
                        idHistorico,
                        cpf,
                        registroMedico,
                        new java.util.Date(dataRegistro.getTime())
                );

                historico.setNomeArquivo("historico_medico_" + idHistorico + ".pdf");

                Log.d(TAG, "DTO criado com sucesso");
                Log.d(TAG, "Tamanho formatado: " + historico.getTamanhoFormatado());

                return historico;
            } else {
                Log.i(TAG, "Nenhum histórico médico encontrado para o CPF: " + cpf);

                return null;
            }

        } catch (SQLException e) {
            Log.e(TAG, "==========================================");
            Log.e(TAG, "ERRO SQL ao buscar histórico médico");
            Log.e(TAG, "Mensagem: " + e.getMessage());
            Log.e(TAG, "SQLState: " + e.getSQLState());
            Log.e(TAG, "ErrorCode: " + e.getErrorCode());
            Log.e(TAG, "==========================================", e);
            return null;
        } catch (Exception e) {
            Log.e(TAG, "==========================================");
            Log.e(TAG, "ERRO GERAL ao buscar histórico médico");
            Log.e(TAG, "Mensagem: " + e.getMessage());
            return null;
        } finally {
            // Fecha recursos
            try {
                if (resultSet != null) {
                    resultSet.close();
                    Log.d(TAG, "ResultSet fechado");
                }
                if (statement != null) {
                    statement.close();
                    Log.d(TAG, "Statement fechado");
                }
            } catch (SQLException e) {
                Log.e(TAG, "Erro ao fechar recursos", e);
            } finally {
                DatabaseHelper.closeConnection(connection);
            }
        }
    }

    /**
     * Insere um novo histórico médico para o paciente
     *
     * @param cpf CPF do paciente
     * @param senha Senha do paciente (para validação)
     * @param pdfBytes Array de bytes do PDF
     * @return true se inserido com sucesso, false caso contrário
     */
    public boolean inserirHistorico(String cpf, String senha, byte[] pdfBytes) {
        Connection connection = null;
        CallableStatement statement = null;
        ResultSet resultSet = null;

        Log.d(TAG, "==========================================");
        Log.d(TAG, "Iniciando inserção de histórico médico");
        Log.d(TAG, "CPF: " + cpf);
        Log.d(TAG, "Tamanho do PDF: " + (pdfBytes != null ? pdfBytes.length : 0) + " bytes");

        try {
            connection = DatabaseHelper.getConnection();
            Log.d(TAG, "Conexão estabelecida com sucesso");

            // Chama a stored procedure Insere_Historico
            String sql = "{CALL Insere_Historico(?, ?, ?)}";
            statement = connection.prepareCall(sql);
            statement.setString(1, cpf);
            statement.setString(2, senha);
            statement.setBytes(3, pdfBytes);

            Log.d(TAG, "Executando procedure: Insere_Historico");

            resultSet = statement.executeQuery();

            if (resultSet.next()) {
                String retorno = resultSet.getString("Retorno_Registra_Historico");
                Log.i(TAG, "Retorno do banco: " + retorno);

                boolean sucesso = retorno.contains("sucesso");

                if (sucesso) {
                    Log.d(TAG, "Histórico médico inserido com SUCESSO!");
                } else {
                    Log.w(TAG, "Falha ao inserir histórico: " + retorno);
                }
                return sucesso;
            }

            Log.w(TAG, "Nenhum retorno da procedure");
            Log.d(TAG, "==========================================");
            return false;

        } catch (SQLException e) {
            Log.e(TAG, "==========================================");
            Log.e(TAG, "ERRO SQL ao inserir histórico médico");
            Log.e(TAG, "Mensagem: " + e.getMessage());
            Log.e(TAG, "SQLState: " + e.getSQLState());
            Log.e(TAG, "ErrorCode: " + e.getErrorCode());
            return false;
        } catch (Exception e) {
            Log.e(TAG, "==========================================");
            Log.e(TAG, "ERRO GERAL ao inserir histórico médico");
            Log.e(TAG, "Mensagem: " + e.getMessage());
            return false;
        } finally {
            // Fecha recursos
            try {
                if (resultSet != null) {
                    resultSet.close();
                    Log.d(TAG, "ResultSet fechado");
                }
                if (statement != null) {
                    statement.close();
                    Log.d(TAG, "Statement fechado");
                }
            } catch (SQLException e) {
                Log.e(TAG, "Erro ao fechar recursos", e);
            } finally {
                DatabaseHelper.closeConnection(connection);
            }
        }
    }

    /**
     * Verifica se o paciente já possui histórico médico cadastrado
     *
     * @param cpf CPF do paciente
     * @return true se já possui histórico, false caso contrário
     */
    public boolean possuiHistorico(String cpf) {
        Log.d(TAG, "Verificando se paciente possui histórico médico. CPF: " + cpf);
        HistoricoMedicoDTO historico = buscarHistoricoPorCPF(cpf);
        boolean possui = historico != null;
        Log.d(TAG, "Possui histórico: " + possui);
        return possui;
    }
}