package com.automacia.mobile.models;

import java.util.Date;

/**
 * DTO para representar um usuário/paciente do sistema
 * Mapeia os campos da tabela Paciente do banco de dados
 */
public class UsuarioDTO {
    private String cpf;           // Paciente_F
    private String nome;          // Nome_Paciente
    private String nomeSocial;    // Nome_Social
    private String email;         // Email
    private String telefone;      // Fone
    private Date dataCriacao;     // Data_Criacao
    private boolean ativo;        // Ativo

    // Campo transitório para login (não persistido)
    private transient String senha;

    // Constructors
    public UsuarioDTO() {}

    public UsuarioDTO(String cpf, String nome, String nomeSocial, String email, String telefone) {
        this.cpf = cpf;
        this.nome = nome;
        this.nomeSocial = nomeSocial;
        this.email = email;
        this.telefone = telefone;
        this.ativo = true;
    }

    // Getters e Setters
    public String getCpf() {
        return cpf;
    }

    public void setCpf(String cpf) {
        this.cpf = cpf;
    }

    public String getNome() {
        return nome;
    }

    public void setNome(String nome) {
        this.nome = nome;
    }

    public String getNomeSocial() {
        return nomeSocial;
    }

    public void setNomeSocial(String nomeSocial) {
        this.nomeSocial = nomeSocial;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getTelefone() {
        return telefone;
    }

    public void setTelefone(String telefone) {
        this.telefone = telefone;
    }

    public Date getDataCriacao() {
        return dataCriacao;
    }

    public void setDataCriacao(Date dataCriacao) {
        this.dataCriacao = dataCriacao;
    }

    public boolean isAtivo() {
        return ativo;
    }

    public void setAtivo(boolean ativo) {
        this.ativo = ativo;
    }

    /**
     * Senha é usada apenas para login e não é persistida no DTO
     * após a autenticação bem-sucedida
     */
    public String getSenha() {
        return senha;
    }

    public void setSenha(String senha) {
        this.senha = senha;
    }

    /**
     * Limpa dados sensíveis do DTO após login bem-sucedido
     */
    public void clearSensitiveData() {
        this.senha = null;
    }

    /**
     * Retorna nome para exibição, priorizando nome social
     */
    public String getNomeExibicao() {
        return (nomeSocial != null && !nomeSocial.trim().isEmpty()) ? nomeSocial : nome;
    }

    @Override
    public String toString() {
        return "UsuarioDTO{" +
                "cpf='" + cpf + '\'' +
                ", nome='" + nome + '\'' +
                ", nomeSocial='" + nomeSocial + '\'' +
                ", email='" + email + '\'' +
                ", telefone='" + telefone + '\'' +
                ", dataCriacao=" + dataCriacao +
                ", ativo=" + ativo +
                '}';
    }
}