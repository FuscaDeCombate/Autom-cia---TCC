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
import androidx.recyclerview.widget.DiffUtil;
import androidx.recyclerview.widget.RecyclerView;
import com.automacia.mobile.R;
import com.automacia.mobile.models.NotificationDTO;
import com.automacia.mobile.models.NotificationItem;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

/**
 * Adapter refatorado com suporte a ViewTypes (HEADER + NOTIFICATION)
 */
public class NotificationAdapter extends RecyclerView.Adapter<RecyclerView.ViewHolder> {

    private static final int VIEW_TYPE_HEADER = 0;
    private static final int VIEW_TYPE_NOTIFICATION = 1;

    private List<NotificationItem> items;
    private final Context context;
    private OnNotificationClickListener listener;
    private final SimpleDateFormat timeFormat;

    public interface OnNotificationClickListener {
        void onNotificationClick(NotificationDTO notification, int position);
    }

    public NotificationAdapter(Context context) {
        this.context = context;
        this.items = new ArrayList<>();
        this.timeFormat = new SimpleDateFormat("HH:mm", Locale.getDefault());
    }

    public void setOnNotificationClickListener(OnNotificationClickListener listener) {
        this.listener = listener;
    }

    @Override
    public int getItemViewType(int position) {
        return items.get(position).isHeader() ? VIEW_TYPE_HEADER : VIEW_TYPE_NOTIFICATION;
    }

    @NonNull
    @Override
    public RecyclerView.ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        if (viewType == VIEW_TYPE_HEADER) {
            View view = LayoutInflater.from(context)
                    .inflate(R.layout.item_notification_header, parent, false);
            return new HeaderViewHolder(view);
        } else {
            View view = LayoutInflater.from(context)
                    .inflate(R.layout.item_notification, parent, false);
            return new NotificationViewHolder(view);
        }
    }

    @Override
    public void onBindViewHolder(@NonNull RecyclerView.ViewHolder holder, int position) {
        NotificationItem item = items.get(position);

        if (holder instanceof HeaderViewHolder) {
            ((HeaderViewHolder) holder).bind(item.getHeaderTitle());
        } else if (holder instanceof NotificationViewHolder) {
            ((NotificationViewHolder) holder).bind(item.getNotification(), position);
        }
    }

    @Override
    public int getItemCount() {
        return items.size();
    }

    /**
     * Atualiza lista usando DiffUtil para performance
     */
    public void updateItems(List<NotificationItem> newItems) {
        DiffUtil.DiffResult diffResult = DiffUtil.calculateDiff(
                new NotificationDiffCallback(this.items, newItems)
        );
        this.items = new ArrayList<>(newItems);
        diffResult.dispatchUpdatesTo(this);
    }

    /**
     * Atualiza lista sem DiffUtil (mais rápido para mudanças pequenas)
     */
    public void setItems(List<NotificationItem> newItems) {
        this.items = new ArrayList<>(newItems);
        notifyDataSetChanged();
    }

    // ViewHolder para Header
    static class HeaderViewHolder extends RecyclerView.ViewHolder {
        private final TextView tvSectionHeader;

        HeaderViewHolder(@NonNull View itemView) {
            super(itemView);
            tvSectionHeader = itemView.findViewById(R.id.tvSectionHeader);
        }

        void bind(String title) {
            tvSectionHeader.setText(title);
        }
    }

    // ViewHolder para Notificação
    class NotificationViewHolder extends RecyclerView.ViewHolder {
        private final CardView cardView;
        private final View unreadIndicator;
        private final CardView iconBackground;
        private final ImageView iconImage;
        private final TextView titleText;
        private final TextView messageText;
        private final TextView timeText;

        NotificationViewHolder(@NonNull View itemView) {
            super(itemView);
            cardView = itemView.findViewById(R.id.cardNotification);
            unreadIndicator = itemView.findViewById(R.id.unreadIndicator);
            iconBackground = itemView.findViewById(R.id.iconBackground);
            iconImage = itemView.findViewById(R.id.iconImage);
            titleText = itemView.findViewById(R.id.titleText);
            messageText = itemView.findViewById(R.id.messageText);
            timeText = itemView.findViewById(R.id.timeText);
        }

        void bind(NotificationDTO notification, int position) {
            titleText.setText(notification.getTitle());
            messageText.setText(notification.getMessage());
            timeText.setText(timeFormat.format(notification.getTimestamp()));

            // Configurar indicador de lida/não lida
            if (notification.isRead()) {
                unreadIndicator.setVisibility(View.INVISIBLE);
                cardView.setAlpha(0.7f);
                cardView.setCardElevation(dpToPx(2f));
            } else {
                unreadIndicator.setVisibility(View.VISIBLE);
                cardView.setAlpha(1.0f);
                cardView.setCardElevation(dpToPx(3f));
            }

            // Configurar ícone e cores baseado no tipo
            setNotificationIcon(notification);

            // Click listener
            itemView.setOnClickListener(v -> {
                if (listener != null) {
                    listener.onNotificationClick(notification, position);
                }
            });
        }

        private void setNotificationIcon(NotificationDTO notification) {
            int iconRes = getIconResource(notification.getIconResource());
            int backgroundColorRes = getColorResource(notification.getBackgroundColorResource());
            int iconTintRes = getColorResource(notification.getIconTintResource());

            iconImage.setImageResource(iconRes);
            iconBackground.setCardBackgroundColor(context.getColor(backgroundColorRes));
            iconImage.setColorFilter(context.getColor(iconTintRes));
        }

        private float dpToPx(float dp) {
            return TypedValue.applyDimension(
                    TypedValue.COMPLEX_UNIT_DIP, dp,
                    context.getResources().getDisplayMetrics()
            );
        }
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
}