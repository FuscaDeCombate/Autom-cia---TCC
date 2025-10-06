package com.automacia.mobile.adapters;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.cardview.widget.CardView;
import androidx.recyclerview.widget.RecyclerView;

import com.automacia.mobile.R;
import com.automacia.mobile.models.PrescriptionDTO;

import java.text.SimpleDateFormat;
import java.util.List;
import java.util.Locale;

public class TimelinePrescriptionAdapter extends RecyclerView.Adapter<TimelinePrescriptionAdapter.PrescriptionViewHolder> {

    private List<PrescriptionDTO> prescriptionList;
    private OnPrescriptionClickListener listener;
    private SimpleDateFormat dateFormat;

    public interface OnPrescriptionClickListener {
        void onPrescriptionClick(PrescriptionDTO prescription);
    }

    public TimelinePrescriptionAdapter(List<PrescriptionDTO> prescriptionList, OnPrescriptionClickListener listener) {
        this.prescriptionList = prescriptionList;
        this.listener = listener;
        this.dateFormat = new SimpleDateFormat("dd/MM/yy", Locale.getDefault());
    }

    @NonNull
    @Override
    public PrescriptionViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        int layoutId = viewType == 1 ? R.layout.timeline_valid_prescription_item : R.layout.timeline_invalid_prescription_item;
        View view = LayoutInflater.from(parent.getContext()).inflate(layoutId, parent, false);
        return new PrescriptionViewHolder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull PrescriptionViewHolder holder, int position) {
        PrescriptionDTO prescription = prescriptionList.get(position);
        holder.bind(prescription, listener, dateFormat);
    }

    @Override
    public int getItemCount() {
        return prescriptionList != null ? prescriptionList.size() : 0;
    }

    @Override
    public int getItemViewType(int position) {
        return prescriptionList.get(position).isValido() ? 1 : 0;
    }

    public void updatePrescriptions(List<PrescriptionDTO> newPrescriptions) {
        this.prescriptionList = newPrescriptions;
        notifyDataSetChanged();
    }

    static class PrescriptionViewHolder extends RecyclerView.ViewHolder {
        private final CardView cardView;
        private final TextView tvMedicationName;
        private final TextView tvStatusBadge;
        private final TextView tvDoctorName;
        private final TextView tvValidityDate;
        private final TextView tvBaixasCount;

        public PrescriptionViewHolder(@NonNull View itemView) {
            super(itemView);

            cardView = (CardView) itemView;
            tvMedicationName = itemView.findViewById(R.id.tv_medication_name);
            tvStatusBadge = itemView.findViewById(R.id.tv_status_badge);
            tvDoctorName = itemView.findViewById(R.id.tv_doctor_name);
            tvValidityDate = itemView.findViewById(R.id.tv_validity_date);
            tvBaixasCount = itemView.findViewById(R.id.tv_baixas_count);
        }

        public void bind(PrescriptionDTO prescription, OnPrescriptionClickListener listener, SimpleDateFormat dateFormat) {
            // Nome do medicamento
            tvMedicationName.setText(prescription.getMedicamento());

            // Nome do médico
            tvDoctorName.setText(prescription.getFuncionarioNome());

            // Contador de baixas
            tvBaixasCount.setText(prescription.getBaixasFormatted());

            // Status e data de validade
            if (prescription.isValido()) {
                tvStatusBadge.setText("VÁLIDA");
                tvValidityDate.setText("Válida até " + dateFormat.format(prescription.getDataValidade()));
            } else {
                tvStatusBadge.setText("INVÁLIDA");
                tvValidityDate.setText("Expirada em " + dateFormat.format(prescription.getDataValidade()));
            }

            // Click listener
            cardView.setOnClickListener(v -> {
                if (listener != null) {
                    listener.onPrescriptionClick(prescription);
                }
            });
        }
    }
}