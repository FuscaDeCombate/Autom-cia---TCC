package com.automacia.mobile.adapters;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.core.content.ContextCompat;
import androidx.recyclerview.widget.RecyclerView;
import com.automacia.mobile.R;
import com.automacia.mobile.models.PrescriptionDTO;
import com.google.android.material.card.MaterialCardView;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;

public class EmergencyMedicationAdapter extends RecyclerView.Adapter<EmergencyMedicationAdapter.ViewHolder> {

    private List<PrescriptionDTO> prescriptions;

    public EmergencyMedicationAdapter(List<PrescriptionDTO> prescriptions) {
        this.prescriptions = new ArrayList<>();
        if (prescriptions != null) {
            this.prescriptions.addAll(prescriptions);
            // PRIORIZAR RECEITAS ATIVAS (válidas) PRIMEIRO
            Collections.sort(this.prescriptions, new Comparator<PrescriptionDTO>() {
                @Override
                public int compare(PrescriptionDTO p1, PrescriptionDTO p2) {
                    // Receitas válidas (ativas) vêm primeiro
                    return Boolean.compare(p2.isValido(), p1.isValido());
                }
            });
        }
    }

    @NonNull
    @Override
    public ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext())
                .inflate(R.layout.item_medication_emergency, parent, false);
        return new ViewHolder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull ViewHolder holder, int position) {
        PrescriptionDTO prescription = prescriptions.get(position);

        holder.tvMedicationName.setText(prescription.getMedicamento());

        // Detalhes ou mensagem padrão
        String details = prescription.getDetalhes();
        if (details != null && !details.trim().isEmpty()) {
            holder.tvMedicationDetails.setText(details);
            holder.tvMedicationDetails.setVisibility(View.VISIBLE);
        } else {
            holder.tvMedicationDetails.setVisibility(View.GONE);
        }

        // Status da receita com Material Design
        if (prescription.isValido()) {
            // Ativa - Verde
            holder.tvStatus.setText("Ativa");
            holder.tvStatus.setTextColor(ContextCompat.getColor(
                    holder.itemView.getContext(), R.color.success));
            holder.statusBadge.setCardBackgroundColor(ContextCompat.getColor(
                    holder.itemView.getContext(), R.color.green_light));
            holder.iconBackground.setCardBackgroundColor(ContextCompat.getColor(
                    holder.itemView.getContext(), R.color.success));
        } else {
            // Inativa - Cinza
            holder.tvStatus.setText("Inativa");
            holder.tvStatus.setTextColor(ContextCompat.getColor(
                    holder.itemView.getContext(), R.color.gray));
            holder.statusBadge.setCardBackgroundColor(ContextCompat.getColor(
                    holder.itemView.getContext(), R.color.gray_light));
            holder.iconBackground.setCardBackgroundColor(ContextCompat.getColor(
                    holder.itemView.getContext(), R.color.gray));
        }
    }

    @Override
    public int getItemCount() {
        return prescriptions.size();
    }

    public List<PrescriptionDTO> getPrescriptions() {
        return prescriptions;
    }

    static class ViewHolder extends RecyclerView.ViewHolder {
        TextView tvMedicationName;
        TextView tvMedicationDetails;
        TextView tvStatus;
        MaterialCardView statusBadge;
        MaterialCardView iconBackground;
        ImageView ivMedicationIcon;

        ViewHolder(View itemView) {
            super(itemView);
            tvMedicationName = itemView.findViewById(R.id.tvMedicationName);
            tvMedicationDetails = itemView.findViewById(R.id.tvMedicationDetails);
            tvStatus = itemView.findViewById(R.id.tvStatus);
            statusBadge = itemView.findViewById(R.id.statusBadge);
            iconBackground = itemView.findViewById(R.id.ivMedicationIcon).getParent() instanceof MaterialCardView
                    ? (MaterialCardView) itemView.findViewById(R.id.ivMedicationIcon).getParent()
                    : null;
            ivMedicationIcon = itemView.findViewById(R.id.ivMedicationIcon);
        }
    }
}