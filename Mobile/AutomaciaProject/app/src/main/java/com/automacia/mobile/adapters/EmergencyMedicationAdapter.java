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
            // FILTRAR APENAS RECEITAS VÁLIDAS
            for (PrescriptionDTO prescription : prescriptions) {
                if (prescription.isValido()) {
                    this.prescriptions.add(prescription);
                }
            }

            // ORDENAR com as mesmas prioridades dos outros adapters
            Collections.sort(this.prescriptions, new Comparator<PrescriptionDTO>() {
                @Override
                public int compare(PrescriptionDTO p1, PrescriptionDTO p2) {
                    // 1. Ordenar por número de baixas (menos baixas primeiro)
                    int baixasCompare = Integer.compare(p1.getBaixas(), p2.getBaixas());
                    if (baixasCompare != 0) {
                        return baixasCompare;
                    }

                    // 2. Ordenar por data (mais recente primeiro)
                    if (p1.getDataReceita() != null && p2.getDataReceita() != null) {
                        return p2.getDataReceita().compareTo(p1.getDataReceita());
                    }

                    return 0;
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

        // Como todas são válidas, sempre mostrar como Ativa - Verde
        holder.tvStatus.setText("Ativa");
        holder.tvStatus.setTextColor(ContextCompat.getColor(
                holder.itemView.getContext(), R.color.success));
        holder.statusBadge.setCardBackgroundColor(ContextCompat.getColor(
                holder.itemView.getContext(), R.color.green_light));
        if (holder.iconBackground != null) {
            holder.iconBackground.setCardBackgroundColor(ContextCompat.getColor(
                    holder.itemView.getContext(), R.color.success));
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