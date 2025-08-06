package com.automacia.mobile;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.cardview.widget.CardView;
import androidx.core.content.ContextCompat;
import androidx.recyclerview.widget.RecyclerView;
import java.util.List;

public class PrescriptionAdapter extends RecyclerView.Adapter<PrescriptionAdapter.PrescriptionViewHolder> {

    private List<HomeFragment.Prescription> prescriptionList;
    private OnPrescriptionClickListener listener;

    public interface OnPrescriptionClickListener {
        void onPrescriptionClick(HomeFragment.Prescription prescription);
    }

    public PrescriptionAdapter(List<HomeFragment.Prescription> prescriptionList, OnPrescriptionClickListener listener) {
        this.prescriptionList = prescriptionList;
        this.listener = listener;
    }

    @NonNull
    @Override
    public PrescriptionViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext())
                .inflate(R.layout.prescription_item, parent, false);
        return new PrescriptionViewHolder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull PrescriptionViewHolder holder, int position) {
        HomeFragment.Prescription prescription = prescriptionList.get(position);
        holder.bind(prescription, listener);
    }

    @Override
    public int getItemCount() {
        return prescriptionList.size();
    }

    public void updatePrescriptions(List<HomeFragment.Prescription> newPrescriptions) {
        this.prescriptionList = newPrescriptions;
        notifyDataSetChanged();
    }

    static class PrescriptionViewHolder extends RecyclerView.ViewHolder {
        private CardView cardPrescription;
        private CardView statusIconCard;
        private ImageView ivPrescriptionStatus;
        private TextView tvPrescriptionTitle;
        private TextView tvPrescriptionDate;
        private TextView tvPrescriptionDoctor;
        private ImageView ivArrow;

        public PrescriptionViewHolder(@NonNull View itemView) {
            super(itemView);

            cardPrescription = (CardView) itemView;
            statusIconCard = itemView.findViewById(R.id.status_icon_card);
            ivPrescriptionStatus = itemView.findViewById(R.id.iv_prescription_status);
            tvPrescriptionTitle = itemView.findViewById(R.id.tv_prescription_title);
            tvPrescriptionDate = itemView.findViewById(R.id.tv_prescription_date);
            tvPrescriptionDoctor = itemView.findViewById(R.id.tv_prescription_doctor);
            ivArrow = itemView.findViewById(R.id.iv_arrow);
        }

        public void bind(HomeFragment.Prescription prescription, OnPrescriptionClickListener listener) {
            tvPrescriptionTitle.setText(prescription.getTitle());
            tvPrescriptionDate.setText("Data: " + prescription.getDate());
            tvPrescriptionDoctor.setText(prescription.getDoctor());

            // Configurar ícone e cor baseado no status
            setupStatusIcon(prescription.getStatus());

            // Configurar clique
            cardPrescription.setOnClickListener(v -> {
                if (listener != null) {
                    listener.onPrescriptionClick(prescription);
                }
            });
        }

        private void setupStatusIcon(HomeFragment.PrescriptionStatus status) {
            int iconRes;
            int colorRes;
            int backgroundColorRes;

            switch (status) {
                case VALID:
                    iconRes = R.drawable.ic_check;
                    colorRes = R.color.white;
                    backgroundColorRes = R.color.success;
                    break;

                case SENT:
                    iconRes = R.drawable.ic_send;
                    colorRes = R.color.white;
                    backgroundColorRes = R.color.primary;
                    break;

                case PROCESSED:
                    iconRes = R.drawable.ic_check;
                    colorRes = R.color.white;
                    backgroundColorRes = R.color.primary;
                    break;

                case EXPIRED:
                    iconRes = R.drawable.ic_warning;
                    colorRes = R.color.white;
                    backgroundColorRes = R.color.red;
                    break;

                case CANCELLED:
                    iconRes = R.drawable.ic_close;
                    colorRes = R.color.white;
                    backgroundColorRes = R.color.gray;
                    break;

                default:
                    iconRes = R.drawable.ic_help;
                    colorRes = R.color.white;
                    backgroundColorRes = R.color.gray;
                    break;
            }

            ivPrescriptionStatus.setImageResource(iconRes);
            ivPrescriptionStatus.setColorFilter(ContextCompat.getColor(itemView.getContext(), colorRes));
            statusIconCard.setCardBackgroundColor(ContextCompat.getColor(itemView.getContext(), backgroundColorRes));
        }
    }
}
