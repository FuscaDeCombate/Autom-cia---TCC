package com.automacia.mobile.models;

import java.util.Date;

public class PrescriptionDTO {
    private int idReceita;
    private Date dataReceita;
    private Date dataValidade;
    private int funcionarioRec;
    private String funcionarioNome;
    private String pacienteF;
    private String medicamento;
    private String detalhes;
    private int limiteBaixas;
    private boolean valido;
    private int baixas;

    // Construtor vazio
    public PrescriptionDTO() {
    }

    // Construtor completo
    public PrescriptionDTO(int idReceita, Date dataReceita, Date dataValidade,
                           int funcionarioRec, String funcionarioNome, String pacienteF,
                           String medicamento, String detalhes, int limiteBaixas,
                           boolean valido, int baixas) {
        this.idReceita = idReceita;
        this.dataReceita = dataReceita;
        this.dataValidade = dataValidade;
        this.funcionarioRec = funcionarioRec;
        this.funcionarioNome = funcionarioNome;
        this.pacienteF = pacienteF;
        this.medicamento = medicamento;
        this.detalhes = detalhes;
        this.limiteBaixas = limiteBaixas;
        this.valido = valido;
        this.baixas = baixas;
    }

    // Getters e Setters
    public int getIdReceita() {
        return idReceita;
    }

    public void setIdReceita(int idReceita) {
        this.idReceita = idReceita;
    }

    public Date getDataReceita() {
        return dataReceita;
    }

    public void setDataReceita(Date dataReceita) {
        this.dataReceita = dataReceita;
    }

    public Date getDataValidade() {
        return dataValidade;
    }

    public void setDataValidade(Date dataValidade) {
        this.dataValidade = dataValidade;
    }

    public int getFuncionarioRec() {
        return funcionarioRec;
    }

    public void setFuncionarioRec(int funcionarioRec) {
        this.funcionarioRec = funcionarioRec;
    }

    public String getFuncionarioNome() {
        return funcionarioNome;
    }

    public void setFuncionarioNome(String funcionarioNome) {
        this.funcionarioNome = funcionarioNome;
    }

    public String getPacienteF() {
        return pacienteF;
    }

    public void setPacienteF(String pacienteF) {
        this.pacienteF = pacienteF;
    }

    public String getMedicamento() {
        return medicamento;
    }

    public void setMedicamento(String medicamento) {
        this.medicamento = medicamento;
    }

    public String getDetalhes() {
        return detalhes;
    }

    public void setDetalhes(String detalhes) {
        this.detalhes = detalhes;
    }

    public int getLimiteBaixas() {
        return limiteBaixas;
    }

    public void setLimiteBaixas(int limiteBaixas) {
        this.limiteBaixas = limiteBaixas;
    }

    public boolean isValido() {
        return valido;
    }

    public void setValido(boolean valido) {
        this.valido = valido;
    }

    public int getBaixas() {
        return baixas;
    }

    public void setBaixas(int baixas) {
        this.baixas = baixas;
    }

    // Métodos auxiliares
    public String getBaixasFormatted() {
        return baixas + "/" + limiteBaixas;
    }

    public boolean isExpired() {
        if (dataValidade == null) return false;
        return dataValidade.before(new Date()) && !valido;
    }
}