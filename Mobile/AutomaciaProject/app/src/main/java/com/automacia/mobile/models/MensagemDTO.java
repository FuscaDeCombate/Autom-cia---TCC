package com.automacia.mobile.models;

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
        SimpleDateFormat sdfHoje = new SimpleDateFormat("yyyyMMdd", Locale.getDefault());
        SimpleDateFormat sdfMensagem = new SimpleDateFormat("yyyyMMdd", Locale.getDefault());

        if (sdfHoje.format(hoje).equals(sdfMensagem.format(horaEnvio))) {
            return "Hoje";
        }

        // Verifica se é ontem
        Date ontem = new Date(hoje.getTime() - 24 * 60 * 60 * 1000);
        if (sdfHoje.format(ontem).equals(sdfMensagem.format(horaEnvio))) {
            return "Ontem";
        }

        // Retorna a data formatada
        SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy", Locale.getDefault());
        return sdf.format(horaEnvio);
    }
}