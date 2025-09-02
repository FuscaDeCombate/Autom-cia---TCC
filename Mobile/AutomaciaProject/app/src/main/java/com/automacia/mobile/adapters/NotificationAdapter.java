package com.automacia.mobile.adapters;

import android.content.Context;
import android.util.TypedValue;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.cardview.widget.CardView;
import androidx.recyclerview.widget.RecyclerView;

import com.automacia.mobile.R;
import com.automacia.mobile.models.Notification;

import java.text.SimpleDateFormat;
import java.util.List;
import java.util.Locale;

public class NotificationAdapter extends RecyclerView.Adapter<NotificationAdapter.NotificationViewHolder> {

    private List<Notification> notifications;
    private Context context;
    private OnNotificationClickListener listener;
    private SimpleDateFormat timeFormat;

    public interface OnNotificationClickListener {
        void onNotificationClick(Notification notification, int position);
    }

    public NotificationAdapter(Context context, List<Notification> notifications) {
        this.context = context;
        this.notifications = notifications;
        this.timeFormat = new SimpleDateFormat("HH:mm", Locale.getDefault());
    }

    public void setOnNotificationClickListener(OnNotificationClickListener listener) {
        this.listener = listener;
    }

    @NonNull
    @Override
    public NotificationViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(context).inflate(R.layout.item_notification, parent, false);
        return new NotificationViewHolder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull NotificationViewHolder holder, int position) {
        Notification notification = notifications.get(position);

        holder.titleText.setText(notification.getTitle());
        holder.messageText.setText(notification.getMessage());
        holder.timeText.setText(timeFormat.format(notification.getTimestamp()));

        // Configurar indicador de lida/não lida
        if (notification.isRead()) {
            holder.unreadIndicator.setVisibility(View.INVISIBLE);
            holder.cardView.setAlpha(0.7f);
            // Converte dp para pixels
            float elevationInPx = TypedValue.applyDimension(
                    TypedValue.COMPLEX_UNIT_DIP, 2f,
                    holder.itemView.getContext().getResources().getDisplayMetrics()
            );
            holder.cardView.setCardElevation(elevationInPx);
        } else {
            holder.unreadIndicator.setVisibility(View.VISIBLE);
            holder.cardView.setAlpha(1.0f);
            float elevationInPx = TypedValue.applyDimension(
                    TypedValue.COMPLEX_UNIT_DIP, 3f,
                    holder.itemView.getContext().getResources().getDisplayMetrics()
            );
            holder.cardView.setCardElevation(elevationInPx);
        }

        // Configurar ícone e cores baseado no tipo
        setNotificationIcon(holder, notification);

        // Click listener
        holder.itemView.setOnClickListener(v -> {
            if (listener != null) {
                // Marcar como lida ao clicar
                if (!notification.isRead()) {
                    notification.setRead(true);
                    notifyItemChanged(position);
                }
                listener.onNotificationClick(notification, position);
            }
        });
    }

    private void setNotificationIcon(NotificationViewHolder holder, Notification notification) {
        int iconRes = getIconResource(notification.getIconResource());
        int backgroundColorRes = getColorResource(notification.getBackgroundColorResource());
        int iconTintRes = getColorResource(notification.getIconTintResource());

        holder.iconImage.setImageResource(iconRes);
        holder.iconBackground.setCardBackgroundColor(context.getColor(backgroundColorRes));
        holder.iconImage.setColorFilter(context.getColor(iconTintRes));
    }

    private int getIconResource(String iconName) {
        switch (iconName) {
            case "ic_warning": return R.drawable.ic_warning;
            case "ic_description": return R.drawable.ic_description;
            case "ic_pharmacy": return R.drawable.ic_pharmacy;
            case "ic_store": return R.drawable.ic_store;
            case "ic_system_update": return R.drawable.ic_system_update;
            case "ic_calendar": return R.drawable.ic_calendar;
            default: return R.drawable.ic_notifications;
        }
    }

    private int getColorResource(String colorName) {
        switch (colorName) {
            case "red": return R.color.red;
            case "red_light": return R.color.red_light;
            case "primary": return R.color.primary;
            case "primary_light": return R.color.primary_light;
            case "green": return R.color.green;
            case "green_light": return R.color.green_light;
            case "blue": return R.color.blue;
            case "blue_light": return R.color.blue_light;
            case "orange": return R.color.orange;
            case "orange_light": return R.color.orange_light;
            case "gray": return R.color.gray;
            case "gray_light": return R.color.gray_light;
            default: return R.color.gray_light;
        }
    }

    @Override
    public int getItemCount() {
        return notifications.size();
    }

    public void updateNotifications(List<Notification> newNotifications) {
        this.notifications = newNotifications;
        notifyDataSetChanged();
    }

    public void markAllAsRead() {
        for (Notification notification : notifications) {
            notification.setRead(true);
        }
        notifyDataSetChanged();
    }

    public static class NotificationViewHolder extends RecyclerView.ViewHolder {
        CardView cardView;
        View unreadIndicator;
        CardView iconBackground;
        ImageView iconImage;
        TextView titleText;
        TextView messageText;
        TextView timeText;

        public NotificationViewHolder(@NonNull View itemView) {
            super(itemView);
            cardView = itemView.findViewById(R.id.cardNotification);
            unreadIndicator = itemView.findViewById(R.id.unreadIndicator);
            iconBackground = itemView.findViewById(R.id.iconBackground);
            iconImage = itemView.findViewById(R.id.iconImage);
            titleText = itemView.findViewById(R.id.titleText);
            messageText = itemView.findViewById(R.id.messageText);
            timeText = itemView.findViewById(R.id.timeText);
        }
    }
}