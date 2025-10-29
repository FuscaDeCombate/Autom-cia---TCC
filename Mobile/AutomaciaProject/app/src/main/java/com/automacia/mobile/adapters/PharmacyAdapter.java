package com.automacia.mobile.adapters;

import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.core.content.ContextCompat;
import androidx.recyclerview.widget.RecyclerView;

import com.automacia.mobile.R;
import com.automacia.mobile.models.PharmacyDTO;

import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

public class PharmacyAdapter extends RecyclerView.Adapter<PharmacyAdapter.PharmacyViewHolder> {

    private Context context;
    private List<PharmacyDTO> pharmacyList;
    private OnPharmacyClickListener listener;

    // Interface para callbacks de clique
    public interface OnPharmacyClickListener {
        void onPharmacyClick(PharmacyDTO pharmacy);
        void onRouteClick(PharmacyDTO pharmacy);
        void onCallClick(PharmacyDTO pharmacy);
        void onDetailsClick(PharmacyDTO pharmacy);
    }

    public PharmacyAdapter(Context context, OnPharmacyClickListener listener) {
        this.context = context;
        this.pharmacyList = new ArrayList<>();
        this.listener = listener;
    }

    @NonNull
    @Override
    public PharmacyViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(context).inflate(R.layout.pharmacy_item, parent, false);
        return new PharmacyViewHolder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull PharmacyViewHolder holder, int position) {
        PharmacyDTO pharmacy = pharmacyList.get(position);
        holder.bind(pharmacy);
    }

    @Override
    public int getItemCount() {
        return pharmacyList.size();
    }

    // Métodos públicos para manipular a lista
    public void setPharmacies(List<PharmacyDTO> pharmacies) {
        this.pharmacyList = pharmacies;
        notifyDataSetChanged();
    }

    public void addPharmacy(PharmacyDTO pharmacy) {
        this.pharmacyList.add(pharmacy);
        notifyItemInserted(pharmacyList.size() - 1);
    }

    public void clearPharmacies() {
        this.pharmacyList.clear();
        notifyDataSetChanged();
    }

    public List<PharmacyDTO> getPharmacies() {
        return pharmacyList;
    }

    public PharmacyDTO getPharmacyAt(int position) {
        if (position >= 0 && position < pharmacyList.size()) {
            return pharmacyList.get(position);
        }
        return null;
    }

    // ViewHolder
    class PharmacyViewHolder extends RecyclerView.ViewHolder {

        TextView pharmacyNameText;
        TextView pharmacyAddressText;
        TextView distanceText;
        TextView statusText;
        TextView hoursText;
        TextView badge24h;
        View statusIndicator;
        LinearLayout callButton;
        LinearLayout routeButton;
        ImageView detailsButton;

        public PharmacyViewHolder(@NonNull View itemView) {
            super(itemView);

            pharmacyNameText = itemView.findViewById(R.id.pharmacyNameText);
            pharmacyAddressText = itemView.findViewById(R.id.pharmacyAddressText);
            distanceText = itemView.findViewById(R.id.distanceText);
            statusText = itemView.findViewById(R.id.statusText);
            hoursText = itemView.findViewById(R.id.hoursText);
            badge24h = itemView.findViewById(R.id.badge24h);
            statusIndicator = itemView.findViewById(R.id.statusIndicator);
            callButton = itemView.findViewById(R.id.callButton);
            routeButton = itemView.findViewById(R.id.routeButton);
            detailsButton = itemView.findViewById(R.id.detailsButton);
        }

        public void bind(PharmacyDTO pharmacy) {
            // Nome e endereço
            pharmacyNameText.setText(pharmacy.getName() != null ? pharmacy.getName() : "Farmácia");
            pharmacyAddressText.setText(pharmacy.getAddress() != null ? pharmacy.getAddress() : "Endereço não disponível");

            // Distância formatada
            if (pharmacy.getDistanceInKm() < 1.0) {
                int meters = (int) (pharmacy.getDistanceInKm() * 1000);
                distanceText.setText(String.valueOf(meters));
                // Muda a unidade para "m" se tiver um TextView separado para unidade
                View parent = (View) distanceText.getParent();
                if (parent instanceof ViewGroup) {
                    ViewGroup distanceLayout = (ViewGroup) parent;
                    for (int i = 0; i < distanceLayout.getChildCount(); i++) {
                        View child = distanceLayout.getChildAt(i);
                        if (child instanceof TextView && child.getId() != R.id.distanceText) {
                            ((TextView) child).setText("m");
                        }
                    }
                }
            } else {
                distanceText.setText(String.format("%.1f", pharmacy.getDistanceInKm()));
            }

            // Status (Aberto/Fechado)
            statusText.setText(pharmacy.getStatusText());
            hoursText.setText(pharmacy.getHoursInfo());

            // Cores do status
            int statusColor;
            if (pharmacy.isOpen()) {
                statusColor = R.color.green;
            } else {
                statusColor = R.color.red;
            }

            statusText.setTextColor(ContextCompat.getColor(context, statusColor));
            statusIndicator.setBackgroundTintList(
                    ContextCompat.getColorStateList(context, statusColor));

            // Badge 24h
            badge24h.setVisibility(pharmacy.is24Hours() ? View.VISIBLE : View.GONE);

            // Click no card inteiro
            itemView.setOnClickListener(v -> {
                if (listener != null) {
                    listener.onPharmacyClick(pharmacy);
                }
            });

            // Botão Ligar
            callButton.setOnClickListener(v -> {
                if (listener != null) {
                    listener.onCallClick(pharmacy);
                }

                // Ação de ligar
                if (pharmacy.getPhone() != null && !pharmacy.getPhone().isEmpty()) {
                    try {
                        Intent intent = new Intent(Intent.ACTION_DIAL);
                        intent.setData(Uri.parse("tel:" + pharmacy.getPhone()));
                        context.startActivity(intent);
                    } catch (Exception e) {
                        Toast.makeText(context, "Não foi possível iniciar a ligação", Toast.LENGTH_SHORT).show();
                    }
                } else {
                    Toast.makeText(context, "Telefone não disponível", Toast.LENGTH_SHORT).show();
                }
            });

            // Botão Rotas
            routeButton.setOnClickListener(v -> {
                if (listener != null) {
                    listener.onRouteClick(pharmacy);
                }

                try {
                    // Se tiver endereço, usa ele
                    String destination;
                    if (pharmacy.getAddress() != null && !pharmacy.getAddress().isEmpty()) {
                        destination = Uri.encode(pharmacy.getAddress());
                    } else {
                        // Fallback: coordenadas
                        destination = pharmacy.getLatitude() + "," + pharmacy.getLongitude();
                    }

                    // URI de rota
                    String uri = "https://www.google.com/maps/dir/?api=1&destination=" + destination + "&travelmode=driving";

                    Intent intent = new Intent(Intent.ACTION_VIEW, Uri.parse(uri));
                    intent.setPackage("com.google.android.apps.maps");

                    if (intent.resolveActivity(context.getPackageManager()) != null) {
                        context.startActivity(intent);
                    } else {
                        // fallback para navegador
                        Intent webIntent = new Intent(Intent.ACTION_VIEW, Uri.parse(uri));
                        context.startActivity(webIntent);
                    }

                } catch (Exception e) {
                    Toast.makeText(context, "Não foi possível abrir o mapa", Toast.LENGTH_SHORT).show();
                }
            });

            // Botão Detalhes
            detailsButton.setOnClickListener(v -> {
                if (listener != null) {
                    listener.onDetailsClick(pharmacy);
                }
            });
        }
    }
}