package com.automacia.mobile.models;

import java.io.Serializable;
import java.util.Date;

/**
 * DTO para representar um histórico médico do paciente
 * Mapeia os campos da tabela Historico_Medico do banco de dados
 */
public class HistoricoMedicoDTO implements Serializable {
    private static final long serialVersionUID = 1L;

    private int idHistorico;          // ID_Historico
    private String cpfPaciente;       // Paciente_F
    private byte[] registroMedico;    // Registro_Medico (PDF em bytes)
    private Date dataRegistro;        // Data_Registro
    private String nomeArquivo;       // Nome do arquivo (gerado)
    private long tamanhoArquivo;      // Tamanho em bytes

    // Constructors
    public HistoricoMedicoDTO() {}

    public HistoricoMedicoDTO(int idHistorico, String cpfPaciente, byte[] registroMedico, Date dataRegistro) {
        this.idHistorico = idHistorico;
        this.cpfPaciente = cpfPaciente;
        this.registroMedico = registroMedico;
        this.dataRegistro = dataRegistro;
        this.tamanhoArquivo = registroMedico != null ? registroMedico.length : 0;
    }

    // Getters e Setters
    public int getIdHistorico() {
        return idHistorico;
    }

    public void setIdHistorico(int idHistorico) {
        this.idHistorico = idHistorico;
    }

    public String getCpfPaciente() {
        return cpfPaciente;
    }

    public void setCpfPaciente(String cpfPaciente) {
        this.cpfPaciente = cpfPaciente;
    }

    public byte[] getRegistroMedico() {
        return registroMedico;
    }

    public void setRegistroMedico(byte[] registroMedico) {
        this.registroMedico = registroMedico;
        this.tamanhoArquivo = registroMedico != null ? registroMedico.length : 0;
    }

    public Date getDataRegistro() {
        return dataRegistro;
    }

    public void setDataRegistro(Date dataRegistro) {
        this.dataRegistro = dataRegistro;
    }

    public String getNomeArquivo() {
        if (nomeArquivo == null || nomeArquivo.isEmpty()) {
            return "historico_medico.pdf";
        }
        return nomeArquivo;
    }

    public void setNomeArquivo(String nomeArquivo) {
        this.nomeArquivo = nomeArquivo;
    }

    public long getTamanhoArquivo() {
        return tamanhoArquivo;
    }

    public void setTamanhoArquivo(long tamanhoArquivo) {
        this.tamanhoArquivo = tamanhoArquivo;
    }

    /**
     * Retorna o tamanho do arquivo formatado (KB, MB)
     */
    public String getTamanhoFormatado() {
        if (tamanhoArquivo < 1024) {
            return tamanhoArquivo + " B";
        } else if (tamanhoArquivo < 1024 * 1024) {
            return String.format("%.2f KB", tamanhoArquivo / 1024.0);
        } else {
            return String.format("%.2f MB", tamanhoArquivo / (1024.0 * 1024.0));
        }
    }

    @Override
    public String toString() {
        return "HistoricoMedicoDTO{" +
                "idHistorico=" + idHistorico +
                ", cpfPaciente='" + cpfPaciente + '\'' +
                ", dataRegistro=" + dataRegistro +
                ", tamanhoArquivo=" + getTamanhoFormatado() +
                '}';
    }
}