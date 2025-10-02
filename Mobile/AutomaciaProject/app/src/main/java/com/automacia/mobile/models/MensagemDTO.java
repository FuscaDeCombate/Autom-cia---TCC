package com.automacia.mobile.models;

import org.json.JSONException;
import org.json.JSONObject;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;

public class MensagemDTO {
    private int idChat;
    private String pacienteCpf;
    private int funcionarioId;
    private String mensagem;
    private Date horaEnvio;
    private boolean ehPaciente; // true se foi enviada pelo paciente, false se pelo funcionário

    // Construtores
    public MensagemDTO() {
        this.horaEnvio = new Date();
    }

    public MensagemDTO(String mensagem, boolean ehPaciente) {
        this();
        this.mensagem = mensagem;
        this.ehPaciente = ehPaciente;
    }

    public MensagemDTO(int idChat, String pacienteCpf, int funcionarioId,
                       String mensagem, Date horaEnvio, boolean ehPaciente) {
        this.idChat = idChat;
        this.pacienteCpf = pacienteCpf;
        this.funcionarioId = funcionarioId;
        this.mensagem = mensagem;
        this.horaEnvio = horaEnvio;
        this.ehPaciente = ehPaciente;
    }

    // Factory method para criar a partir de ResultSet
    public static MensagemDTO fromResultSet(ResultSet rs) throws SQLException {
        MensagemDTO msg = new MensagemDTO();
        msg.setIdChat(rs.getInt("Id_Chat"));
        msg.setPacienteCpf(rs.getString("Paciente_F"));
        msg.setFuncionarioId(rs.getInt("Funcionar_Rec"));
        msg.setMensagem(rs.getString("Mensagem"));
        msg.setHoraEnvio(rs.getTimestamp("Hora_Envio"));
        msg.setEhPaciente(rs.getBoolean("MsgPaciente"));
        return msg;
    }

    // Factory method para criar a partir de JSON
    public static MensagemDTO fromJSON(JSONObject json) throws JSONException {
        MensagemDTO msg = new MensagemDTO();

        if (json.has("idChat")) msg.setIdChat(json.getInt("idChat"));
        if (json.has("pacienteCpf")) msg.setPacienteCpf(json.getString("pacienteCpf"));
        if (json.has("funcionarioId")) msg.setFuncionarioId(json.getInt("funcionarioId"));
        if (json.has("mensagem")) msg.setMensagem(json.getString("mensagem"));
        if (json.has("horaEnvio")) msg.setHoraEnvio(new Date(json.getLong("horaEnvio")));
        if (json.has("ehPaciente")) msg.setEhPaciente(json.getBoolean("ehPaciente"));

        return msg;
    }

    // Getters e Setters
    public int getIdChat() {
        return idChat;
    }

    public void setIdChat(int idChat) {
        this.idChat = idChat;
    }

    public String getPacienteCpf() {
        return pacienteCpf;
    }

    public void setPacienteCpf(String pacienteCpf) {
        this.pacienteCpf = pacienteCpf;
    }

    public int getFuncionarioId() {
        return funcionarioId;
    }

    public void setFuncionarioId(int funcionarioId) {
        this.funcionarioId = funcionarioId;
    }

    public String getMensagem() {
        return mensagem;
    }

    public void setMensagem(String mensagem) {
        this.mensagem = mensagem;
    }

    public Date getHoraEnvio() {
        return horaEnvio;
    }

    public void setHoraEnvio(Date horaEnvio) {
        this.horaEnvio = horaEnvio;
    }

    public boolean isEhPaciente() {
        return ehPaciente;
    }

    public void setEhPaciente(boolean ehPaciente) {
        this.ehPaciente = ehPaciente;
    }

    // Métodos utilitários
    public String getOrigem() {
        return ehPaciente ? "Paciente" : "Funcionário";
    }

    public String getHoraFormatada() {
        if (horaEnvio == null) return "";
        SimpleDateFormat sdf = new SimpleDateFormat("HH:mm", Locale.getDefault());
        return sdf.format(horaEnvio);
    }

    public String getDataFormatada() {
        if (horaEnvio == null) return "";
        SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy", Locale.getDefault());
        return sdf.format(horaEnvio);
    }

    public String getDataHoraFormatada() {
        if (horaEnvio == null) return "";
        SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm", Locale.getDefault());
        return sdf.format(horaEnvio);
    }

    public boolean isMesmoData(MensagemDTO outraMensagem) {
        if (this.horaEnvio == null || outraMensagem.getHoraEnvio() == null) {
            return false;
        }

        SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd", Locale.getDefault());
        return sdf.format(this.horaEnvio).equals(sdf.format(outraMensagem.getHoraEnvio()));
    }

    public String getDataRelativa() {
        if (horaEnvio == null) return "";

        Date hoje = new Date();
        SimpleDateFormat sdfComparacao = new SimpleDateFormat("yyyyMMdd", Locale.getDefault());

        String dataHoje = sdfComparacao.format(hoje);
        String dataMensagem = sdfComparacao.format(horaEnvio);

        if (dataHoje.equals(dataMensagem)) {
            return "Hoje";
        }

        // Verifica se é ontem
        Date ontem = new Date(hoje.getTime() - 24 * 60 * 60 * 1000);
        String dataOntem = sdfComparacao.format(ontem);

        if (dataOntem.equals(dataMensagem)) {
            return "Ontem";
        }

        // Retorna a data formatada
        SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy", Locale.getDefault());
        return sdf.format(horaEnvio);
    }

    // Conversão para JSON (útil para APIs/sockets)
    public JSONObject toJSON() throws JSONException {
        JSONObject json = new JSONObject();
        json.put("idChat", idChat);
        json.put("pacienteCpf", pacienteCpf);
        json.put("funcionarioId", funcionarioId);
        json.put("mensagem", mensagem);
        json.put("horaEnvio", horaEnvio != null ? horaEnvio.getTime() : 0);
        json.put("ehPaciente", ehPaciente);
        json.put("origem", getOrigem());
        json.put("horaFormatada", getHoraFormatada());
        json.put("dataFormatada", getDataFormatada());
        return json;
    }

    @Override
    public String toString() {
        return "MensagemDTO{" +
                "idChat=" + idChat +
                ", pacienteCpf='" + pacienteCpf + '\'' +
                ", funcionarioId=" + funcionarioId +
                ", mensagem='" + mensagem + '\'' +
                ", horaEnvio=" + getDataHoraFormatada() +
                ", origem=" + getOrigem() +
                '}';
    }
}