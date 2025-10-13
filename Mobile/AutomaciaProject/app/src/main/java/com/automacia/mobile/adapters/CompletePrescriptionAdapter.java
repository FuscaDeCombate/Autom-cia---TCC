package com.automacia.mobile.adapters;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.automacia.mobile.R;
import com.automacia.mobile.models.PrescriptionDTO;
import com.automacia.mobile.utils.Utils;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Locale;

public class CompletePrescriptionAdapter extends RecyclerView.Adapter<RecyclerView.ViewHolder> {
    private static final int VIEW_TYPE_VALID = 1;
    private static final int VIEW_TYPE_INVALID = 2;

    private List<PrescriptionDTO> prescriptions;
    private SimpleDateFormat dateFormat;

    public CompletePrescriptionAdapter(){
        this.prescriptions = new ArrayList<>();
        this.dateFormat = new SimpleDateFormat("dd/MM/yy", Locale.getDefault());
    }

    @Override
    public int getItemViewType(int position) {
        PrescriptionDTO prescription = prescriptions.get(position);
        return prescription.isValido() ? VIEW_TYPE_VALID : VIEW_TYPE_INVALID;
    }

    @NonNull
    @Override
    public RecyclerView.ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        LayoutInflater inflater = LayoutInflater.from(parent.getContext());

        if (viewType == VIEW_TYPE_VALID) {
            View view = inflater.inflate(R.layout.complete_valid_prescription_item, parent, false);
            return new ValidPrescriptionViewHolder(view);
        } else {
            View view = inflater.inflate(R.layout.complete_invalid_prescription_item, parent, false);
            return new InvalidPrescriptionViewHolder(view);
        }
    }

    @Override
    public void onBindViewHolder(@NonNull RecyclerView.ViewHolder holder, int position) {
        PrescriptionDTO prescription = prescriptions.get(position);

        if (holder instanceof ValidPrescriptionViewHolder) {
            ((ValidPrescriptionViewHolder) holder).bind(prescription);
        } else if (holder instanceof InvalidPrescriptionViewHolder) {
            ((InvalidPrescriptionViewHolder) holder).bind(prescription);
        }
    }

    @Override
    public int getItemCount() {
        return prescriptions.size();
    }

    public void setPrescriptions(List<PrescriptionDTO> prescriptions) {
        this.prescriptions = prescriptions != null ? prescriptions : new ArrayList<>();
        notifyDataSetChanged();
    }

    public void addPrescription(PrescriptionDTO prescription) {
        this.prescriptions.add(prescription);
        notifyItemInserted(prescriptions.size() - 1);
    }

    public void clear() {
        this.prescriptions.clear();
        notifyDataSetChanged();
    }

    // ViewHolder para Receitas Válidas
    class ValidPrescriptionViewHolder extends RecyclerView.ViewHolder {
        TextView tvRxId;
        TextView tvMedicationName;
        TextView tvDoctorAvatar;
        TextView tvDoctorName;
        TextView tvPrescriptionDate;
        TextView tvExpiryDate;
        TextView tvPatientCpf;
        TextView tvEmissionTime;
        TextView tvDetails;
        TextView tvUsedCount;
        TextView tvTotalCount;
        TextView tvRemainingCount;

        public ValidPrescriptionViewHolder(@NonNull View itemView) {
            super(itemView);
            tvRxId = itemView.findViewById(R.id.tvRxId);
            tvMedicationName = itemView.findViewById(R.id.tvMedicationName);
            tvDoctorAvatar = itemView.findViewById(R.id.tvDoctorAvatar);
            tvDoctorName = itemView.findViewById(R.id.tvDoctorName);
            tvPrescriptionDate = itemView.findViewById(R.id.tvPrescriptionDate);
            tvExpiryDate = itemView.findViewById(R.id.tvExpiryDate);
            tvPatientCpf = itemView.findViewById(R.id.tvPatientCpf);
            tvEmissionTime = itemView.findViewById(R.id.tvEmissionTime);
            tvDetails = itemView.findViewById(R.id.tvDetails);
            tvUsedCount = itemView.findViewById(R.id.tvUsedCount);
            tvTotalCount = itemView.findViewById(R.id.tvTotalCount);
            tvRemainingCount = itemView.findViewById(R.id.tvRemainingCount);
        }

        public void bind(PrescriptionDTO prescription) {
            // ID da receita
            tvRxId.setText("#" + prescription.getIdReceita());

            // Nome do medicamento
            tvMedicationName.setText(prescription.getMedicamento());

            // Avatar e nome do médico
            tvDoctorAvatar.setText(getInitials(prescription.getFuncionarioNome()));
            tvDoctorName.setText(prescription.getFuncionarioNome());

            // Data da receita
            tvPrescriptionDate.setText(formatDate(prescription.getDataReceita()));

            // Data de validade
            tvExpiryDate.setText(formatDate(prescription.getDataValidade()));

            // CPF do paciente
            tvPatientCpf.setText(Utils.formatCpf(prescription.getPacienteF()));

            // Hora de emissão (extrair da dataReceita)
            tvEmissionTime.setText(formatTime(prescription.getDataReceita()));

            // Detalhes/instruções
            tvDetails.setText(prescription.getDetalhes() != null && !prescription.getDetalhes().isEmpty()
                    ? prescription.getDetalhes()
                    : "Sem instruções adicionais.");

            // Estatísticas
            tvUsedCount.setText(String.valueOf(prescription.getBaixas()));
            tvTotalCount.setText(String.valueOf(prescription.getLimiteBaixas()));

            int remaining = prescription.getLimiteBaixas() - prescription.getBaixas();
            tvRemainingCount.setText(String.valueOf(Math.max(0, remaining)));
        }
    }

    // ViewHolder para Receitas Inválidas
    class InvalidPrescriptionViewHolder extends RecyclerView.ViewHolder {
        TextView tvRxId;
        TextView tvMedicationName;
        TextView tvDoctorAvatar;
        TextView tvDoctorName;
        TextView tvPrescriptionDate;
        TextView tvExpiryDate;
        TextView tvPatientCpf;
        TextView tvEmissionTime;
        TextView tvDetails;
        TextView tvUsedCount;
        TextView tvTotalCount;
        TextView tvRemainingCount;

        public InvalidPrescriptionViewHolder(@NonNull View itemView) {
            super(itemView);
            tvRxId = itemView.findViewById(R.id.tvRxId);
            tvMedicationName = itemView.findViewById(R.id.tvMedicationName);
            tvDoctorAvatar = itemView.findViewById(R.id.tvDoctorAvatar);
            tvDoctorName = itemView.findViewById(R.id.tvDoctorName);
            tvPrescriptionDate = itemView.findViewById(R.id.tvPrescriptionDate);
            tvExpiryDate = itemView.findViewById(R.id.tvExpiryDate);
            tvPatientCpf = itemView.findViewById(R.id.tvPatientCpf);
            tvEmissionTime = itemView.findViewById(R.id.tvEmissionTime);
            tvDetails = itemView.findViewById(R.id.tvDetails);
            tvUsedCount = itemView.findViewById(R.id.tvUsedCount);
            tvTotalCount = itemView.findViewById(R.id.tvTotalCount);
            tvRemainingCount = itemView.findViewById(R.id.tvRemainingCount);
        }

        public void bind(PrescriptionDTO prescription) {
            // ID da receita
            tvRxId.setText("#" + prescription.getIdReceita());

            // Nome do medicamento
            tvMedicationName.setText(prescription.getMedicamento());

            // Avatar e nome do médico
            tvDoctorAvatar.setText(getInitials(prescription.getFuncionarioNome()));
            tvDoctorName.setText(prescription.getFuncionarioNome());

            // Data da receita
            tvPrescriptionDate.setText(formatDate(prescription.getDataReceita()));

            // Data de validade
            tvExpiryDate.setText(formatDate(prescription.getDataValidade()));

            // CPF do paciente
            tvPatientCpf.setText(Utils.formatCpf(prescription.getPacienteF()));

            // Hora de emissão (extrair da dataReceita)
            tvEmissionTime.setText(formatTime(prescription.getDataReceita()));

            // Detalhes/instruções
            tvDetails.setText(prescription.getDetalhes() != null && !prescription.getDetalhes().isEmpty()
                    ? prescription.getDetalhes()
                    : "Sem instruções adicionais.");

            // Estatísticas
            tvUsedCount.setText(String.valueOf(prescription.getBaixas()));
            tvTotalCount.setText(String.valueOf(prescription.getLimiteBaixas()));

            int remaining = prescription.getLimiteBaixas() - prescription.getBaixas();
            tvRemainingCount.setText(String.valueOf(Math.max(0, remaining)));
        }
    }

    /**
     * Formata a data no padrão dd/MM/yy
     */
    private String formatDate(Date date) {
        if (date == null) return "N/A";
        return dateFormat.format(date);
    }

    /**
     * Extrai e formata a hora da data no padrão HH:mm
     */
    private String formatTime(Date date) {
        if (date == null) return "00:00";
        SimpleDateFormat timeFormat = new SimpleDateFormat("HH:mm", Locale.getDefault());
        return timeFormat.format(date);
    }

    /**
     * Extrai as iniciais do nome (primeiras letras de cada palavra)
     */
    private String getInitials(String name) {
        if (name == null || name.trim().isEmpty()) return "??";

        String[] parts = name.trim().split("\\s+");
        StringBuilder initials = new StringBuilder();

        // Pega a primeira letra de cada palavra (máximo 2)
        int count = 0;
        for (String part : parts) {
            if (count >= 2) break;
            if (!part.isEmpty()) {
                initials.append(part.charAt(0));
                count++;
            }
        }

        return initials.toString().toUpperCase();
    }
}
