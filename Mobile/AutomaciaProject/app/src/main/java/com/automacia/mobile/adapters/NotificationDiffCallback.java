package com.automacia.mobile.adapters;

import androidx.recyclerview.widget.DiffUtil;
import com.automacia.mobile.models.NotificationItem;
import java.util.List;

/**
 * DiffUtil callback para atualizar notificações de forma eficiente
 */
public class NotificationDiffCallback extends DiffUtil.Callback {

    private final List<NotificationItem> oldList;
    private final List<NotificationItem> newList;

    public NotificationDiffCallback(List<NotificationItem> oldList, List<NotificationItem> newList) {
        this.oldList = oldList;
        this.newList = newList;
    }

    @Override
    public int getOldListSize() {
        return oldList.size();
    }

    @Override
    public int getNewListSize() {
        return newList.size();
    }

    @Override
    public boolean areItemsTheSame(int oldItemPosition, int newItemPosition) {
        NotificationItem oldItem = oldList.get(oldItemPosition);
        NotificationItem newItem = newList.get(newItemPosition);

        // Se tipos diferentes, não são iguais
        if (oldItem.getItemType() != newItem.getItemType()) {
            return false;
        }

        // Se ambos são headers, compara título
        if (oldItem.isHeader() && newItem.isHeader()) {
            return oldItem.getHeaderTitle().equals(newItem.getHeaderTitle());
        }

        // Se ambos são notificações, compara ID
        if (oldItem.isNotification() && newItem.isNotification()) {
            return oldItem.getNotification().getId() == newItem.getNotification().getId();
        }

        return false;
    }

    @Override
    public boolean areContentsTheSame(int oldItemPosition, int newItemPosition) {
        NotificationItem oldItem = oldList.get(oldItemPosition);
        NotificationItem newItem = newList.get(newItemPosition);

        // Headers sempre têm mesmo conteúdo se título igual
        if (oldItem.isHeader() && newItem.isHeader()) {
            return oldItem.getHeaderTitle().equals(newItem.getHeaderTitle());
        }

        // Para notificações, compara campos relevantes
        if (oldItem.isNotification() && newItem.isNotification()) {
            return areNotificationsEqual(oldItem.getNotification(), newItem.getNotification());
        }

        return false;
    }

    private boolean areNotificationsEqual(
            com.automacia.mobile.models.NotificationDTO old,
            com.automacia.mobile.models.NotificationDTO newN) {
        return old.getId() == newN.getId() &&
                old.isRead() == newN.isRead() &&
                old.getTitle().equals(newN.getTitle()) &&
                old.getMessage().equals(newN.getMessage()) &&
                old.getTimestamp().equals(newN.getTimestamp());
    }
}