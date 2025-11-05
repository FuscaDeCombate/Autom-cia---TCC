package com.automacia.mobile.storage;

import android.content.Context;
import android.content.SharedPreferences;
import com.automacia.mobile.models.NotificationDTO;
import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;
import java.lang.reflect.Type;
import java.util.ArrayList;
import java.util.List;

/**
 * Classe responsável pela persistência de notificações usando SharedPreferences + Gson
 */
public class NotificationStorage {
    private static final String PREFS_NAME = "automacia_notifications";
    private static final String KEY_NOTIFICATIONS = "notifications_list";

    private final SharedPreferences prefs;
    private final Gson gson;

    public NotificationStorage(Context context) {
        this.prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE);
        this.gson = new Gson();
    }

    /**
     * Salva lista de notificações no SharedPreferences
     */
    public void saveNotifications(List<NotificationDTO> notifications) {
        try {
            String json = gson.toJson(notifications);
            prefs.edit().putString(KEY_NOTIFICATIONS, json).apply();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /**
     * Carrega lista de notificações do SharedPreferences
     */
    public List<NotificationDTO> loadNotifications() {
        try {
            String json = prefs.getString(KEY_NOTIFICATIONS, "[]");
            Type listType = new TypeToken<List<NotificationDTO>>(){}.getType();
            List<NotificationDTO> notifications = gson.fromJson(json, listType);
            return notifications != null ? notifications : new ArrayList<>();
        } catch (Exception e) {
            e.printStackTrace();
            return new ArrayList<>();
        }
    }

    /**
     * Marca uma notificação específica como lida
     */
    public void markAsRead(int notificationId) {
        List<NotificationDTO> notifications = loadNotifications();
        boolean changed = false;

        for (NotificationDTO notification : notifications) {
            if (notification.getId() == notificationId && !notification.isRead()) {
                notification.setRead(true);
                changed = true;
                break;
            }
        }

        if (changed) {
            saveNotifications(notifications);
        }
    }

    /**
     * Marca todas as notificações como lidas
     */
    public void markAllAsRead() {
        List<NotificationDTO> notifications = loadNotifications();
        boolean changed = false;

        for (NotificationDTO notification : notifications) {
            if (!notification.isRead()) {
                notification.setRead(true);
                changed = true;
            }
        }

        if (changed) {
            saveNotifications(notifications);
        }
    }

    /**
     * Adiciona uma nova notificação
     */
    public void addNotification(NotificationDTO notification) {
        List<NotificationDTO> notifications = loadNotifications();
        notifications.add(0, notification); // Adiciona no início
        saveNotifications(notifications);
    }

    /**
     * Remove uma notificação específica
     */
    public void removeNotification(int notificationId) {
        List<NotificationDTO> notifications = loadNotifications();
        notifications.removeIf(n -> n.getId() == notificationId);
        saveNotifications(notifications);
    }

    /**
     * Limpa todas as notificações
     */
    public void clearAll() {
        prefs.edit().remove(KEY_NOTIFICATIONS).apply();
    }
}