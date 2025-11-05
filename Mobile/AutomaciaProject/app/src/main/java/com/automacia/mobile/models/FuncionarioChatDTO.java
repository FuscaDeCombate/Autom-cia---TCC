package com.automacia.mobile.models;

public class FuncionarioChatDTO {
    private String funcionarioRec;
    private String nomeFuncionario;
    private String tipoFuncionario;
    private String hospital;
    private boolean chatAberto;
    private boolean ativo;

    // Construtor vazio
    public FuncionarioChatDTO() {
    }

    // Construtor completo
    public FuncionarioChatDTO(String funcionarioRec, String nomeFuncionario,
                              String tipoFuncionario, String hospital,
                              boolean chatAberto, boolean ativo) {
        this.funcionarioRec = funcionarioRec;
        this.nomeFuncionario = nomeFuncionario;
        this.tipoFuncionario = tipoFuncionario;
        this.hospital = hospital;
        this.chatAberto = chatAberto;
        this.ativo = ativo;
    }

    // Getters e Setters
    public String getFuncionarioRec() {
        return funcionarioRec;
    }

    public void setFuncionarioRec(String funcionarioRec) {
        this.funcionarioRec = funcionarioRec;
    }

    public String getNomeFuncionario() {
        return nomeFuncionario;
    }

    public void setNomeFuncionario(String nomeFuncionario) {
        this.nomeFuncionario = nomeFuncionario;
    }

    public String getTipoFuncionario() {
        return tipoFuncionario;
    }

    public void setTipoFuncionario(String tipoFuncionario) {
        this.tipoFuncionario = tipoFuncionario;
    }

    public String getHospital() {
        return hospital;
    }

    public void setHospital(String hospital) {
        this.hospital = hospital;
    }

    public boolean isChatAberto() {
        return chatAberto;
    }

    public void setChatAberto(boolean chatAberto) {
        this.chatAberto = chatAberto;
    }

    public boolean isAtivo() {
        return ativo;
    }

    public void setAtivo(boolean ativo) {
        this.ativo = ativo;
    }

    @Override
    public String toString() {
        return "FuncionarioChatDTO{" +
                "funcionarioRec='" + funcionarioRec + '\'' +
                ", nomeFuncionario='" + nomeFuncionario + '\'' +
                ", tipoFuncionario='" + tipoFuncionario + '\'' +
                ", hospital='" + hospital + '\'' +
                ", chatAberto=" + chatAberto +
                ", ativo=" + ativo +
                '}';
    }
}