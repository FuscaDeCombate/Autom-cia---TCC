package com.automacia.mobile.services;

import android.util.Log;

import com.automacia.mobile.models.UsuarioDTO;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;

/**
 * Service responsável por operações relacionadas ao perfil do paciente
 * Gerencia atualizações de dados pessoais e interação com stored procedures
 */
public class PerfilService {

    private static final String TAG = "PerfilService";

    /**
     * Resultado da operação de atualização de perfil
     */
    public static class ResultadoAtualizacao {
        private final boolean sucesso;
        private final String mensagem;
        private final String mensagemDetalhada;

        public ResultadoAtualizacao(boolean sucesso, String mensagem, String mensagemDetalhada) {
            this.sucesso = sucesso;
            this.mensagem = mensagem;
            this.mensagemDetalhada = mensagemDetalhada;
        }

        public boolean isSucesso() {
            return sucesso;
        }

        public String getMensagem() {
            return mensagem;
        }

        public String getMensagemDetalhada() {
            return mensagemDetalhada;
        }
    }

    /**
     * Atualiza os dados do perfil do paciente
     *
     * @param usuario Objeto UsuarioDTO com os dados atualizados
     * @param senha Senha do usuário para validação
     * @return ResultadoAtualizacao contendo sucesso/erro e mensagens
     */
    public static ResultadoAtualizacao atualizarPerfil(UsuarioDTO usuario, String senha) {
        Connection connection = null;
        CallableStatement statement = null;
        ResultSet resultSet = null;

        try {
            // Validações básicas antes de chamar o banco
            if (usuario == null || usuario.getCpf() == null || usuario.getCpf().isEmpty()) {
                String erro = "Dados do usuário inválidos";
                Log.e(TAG, erro + " - UsuarioDTO nulo ou CPF vazio");
                return new ResultadoAtualizacao(false, erro, "CPF não fornecido");
            }

            if (senha == null || senha.isEmpty()) {
                String erro = "Senha não fornecida";
                Log.e(TAG, erro + " para CPF: " + usuario.getCpf());
                return new ResultadoAtualizacao(false, erro, "Senha é obrigatória para atualizar o perfil");
            }

            Log.d(TAG, "Iniciando atualização de perfil para CPF: " + usuario.getCpf());

            // Estabelecer conexão
            connection = DatabaseHelper.getConnection();

            if (connection == null || connection.isClosed()) {
                String erro = "Erro ao conectar ao banco de dados";
                Log.e(TAG, erro + " - Connection null ou fechada");
                return new ResultadoAtualizacao(false, erro, "Não foi possível estabelecer conexão com o servidor");
            }

            // Preparar chamada da stored procedure
            String procedureCall = "{CALL Alt_Paciente(?, ?, ?, ?, ?, ?)}";
            statement = connection.prepareCall(procedureCall);

            // Definir parâmetros
            statement.setString(1, usuario.getCpf());           // @CPF_Alt_P
            statement.setString(2, senha);                       // @Senha_Alt_P
            statement.setString(3, usuario.getEmail());          // @Email_Alt_P
            statement.setString(4, usuario.getNome());           // @Nome_Alt_P
            statement.setString(6, usuario.getTelefone());       // @Telefone_Alt_p

            // Nome social pode ser null ou vazio
            String nomeSocial = usuario.getNomeSocial();
            if (nomeSocial == null || nomeSocial.trim().isEmpty()) {
                statement.setString(5, "");  // @Nome_Social_Alt_P
            } else {
                statement.setString(5, nomeSocial);
            }

            Log.d(TAG, "Executando procedure Alt_Paciente com parâmetros: " +
                    "CPF=" + usuario.getCpf() + ", " +
                    "Email=" + usuario.getEmail() + ", " +
                    "Nome=" + usuario.getNome() + ", " +
                    "Telefone="+ usuario.getTelefone() + ", " +
                    "NomeSocial=" + (nomeSocial != null ? nomeSocial : "vazio"));

            // Executar procedure
            resultSet = statement.executeQuery();

            // Processar retorno
            if (resultSet.next()) {
                String retorno = resultSet.getString("Retorno_Altera_Paciente");
                Log.d(TAG, "Retorno da procedure: " + retorno);

                // Verificar se foi sucesso
                if (retorno != null && retorno.contains("sucesso")) {
                    Log.i(TAG, "Perfil atualizado com sucesso para CPF: " + usuario.getCpf());
                    return new ResultadoAtualizacao(true, "Dados atualizados com sucesso!", retorno);
                } else {
                    // Erro retornado pela procedure
                    Log.w(TAG, "Procedure retornou erro: " + retorno);
                    return new ResultadoAtualizacao(false, retorno, "Erro retornado pelo servidor: " + retorno);
                }
            } else {
                String erro = "Nenhum retorno da procedure";
                Log.e(TAG, erro + " - ResultSet vazio");
                return new ResultadoAtualizacao(false, "Erro ao processar resposta do servidor", erro);
            }

        } catch (SQLException e) {
            String erro = "Erro SQL ao atualizar perfil";
            String detalhes = "SQLException: " + e.getMessage() +
                    "\nSQLState: " + e.getSQLState() +
                    "\nErrorCode: " + e.getErrorCode();
            Log.e(TAG, erro + " para CPF: " + (usuario != null ? usuario.getCpf() : "null"), e);
            Log.e(TAG, detalhes);

            // Mensagens de erro mais amigáveis
            String mensagemUsuario;
            if (e.getMessage() != null && e.getMessage().contains("timeout")) {
                mensagemUsuario = "Tempo de resposta excedido. Tente novamente.";
            } else if (e.getMessage() != null && e.getMessage().contains("connection")) {
                mensagemUsuario = "Erro de conexão com o servidor.";
            } else {
                mensagemUsuario = "Erro ao salvar dados. Tente novamente.";
            }

            return new ResultadoAtualizacao(false, mensagemUsuario, detalhes);

        } catch (Exception e) {
            String erro = "Erro inesperado ao atualizar perfil";
            String detalhes = e.getClass().getName() + ": " + e.getMessage();
            Log.e(TAG, erro + " para CPF: " + (usuario != null ? usuario.getCpf() : "null"), e);

            return new ResultadoAtualizacao(false, "Erro inesperado. Tente novamente.", detalhes);

        } finally {
            // Fechar recursos na ordem correta
            try {
                if (resultSet != null && !resultSet.isClosed()) {
                    resultSet.close();
                    Log.d(TAG, "ResultSet fechado");
                }
            } catch (SQLException e) {
                Log.e(TAG, "Erro ao fechar ResultSet", e);
            }

            try {
                if (statement != null && !statement.isClosed()) {
                    statement.close();
                    Log.d(TAG, "Statement fechado");
                }
            } catch (SQLException e) {
                Log.e(TAG, "Erro ao fechar Statement", e);
            }

            DatabaseHelper.closeConnection(connection);
        }
    }
}