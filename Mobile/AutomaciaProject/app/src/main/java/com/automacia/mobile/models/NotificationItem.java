package com.automacia.mobile.models;

/**
 * Classe wrapper para representar itens no RecyclerView
 * Pode ser um HEADER (título de seção) ou NOTIFICATION (notificação real)
 */
public class NotificationItem {

    public enum ItemType {
        HEADER,
        NOTIFICATION
    }

    private final ItemType itemType;
    private final String headerTitle;
    private final NotificationDTO notification;

    // Construtor para HEADER
    private NotificationItem(String headerTitle) {
        this.itemType = ItemType.HEADER;
        this.headerTitle = headerTitle;
        this.notification = null;
    }

    // Construtor para NOTIFICATION
    private NotificationItem(NotificationDTO notification) {
        this.itemType = ItemType.NOTIFICATION;
        this.notification = notification;
        this.headerTitle = null;
    }

    // Factory methods
    public static NotificationItem createHeader(String title) {
        return new NotificationItem(title);
    }

    public static NotificationItem createNotification(NotificationDTO notification) {
        return new NotificationItem(notification);
    }

    // Getters
    public ItemType getItemType() {
        return itemType;
    }

    public String getHeaderTitle() {
        return headerTitle;
    }

    public NotificationDTO getNotification() {
        return notification;
    }

    public boolean isHeader() {
        return itemType == ItemType.HEADER;
    }

    public boolean isNotification() {
        return itemType == ItemType.NOTIFICATION;
    }
}