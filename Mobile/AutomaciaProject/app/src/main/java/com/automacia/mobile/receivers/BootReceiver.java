package com.automacia.mobile.receivers;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import com.automacia.mobile.models.NotificationDTO;
import com.automacia.mobile.utils.NotificationScheduler;
import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;
import java.lang.reflect.Type;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

/**
 * Receiver que reagenda notificações após o celular reiniciar
 * (AlarmManager perde os alarmes após reboot)
 */
public class BootReceiver extends BroadcastReceiver {

    private static final String PREFS_NAME = "automacia_scheduled_notifications";
    private static final String KEY_SCHEDULED = "scheduled_list";

    @Override
    public void onReceive(Context context, Intent intent) {
        if (intent == null || intent.getAction() == null) {
            return;
        }

        if (Intent.ACTION_BOOT_COMPLETED.equals(intent.getAction()) ||
                "android.intent.action.BOOT_COMPLETED".equals(intent.getAction())) {
            rescheduleNotifications(context);
        }
    }

    /**
     * Reagenda todas as notificações pendentes
     */
    private void rescheduleNotifications(Context context) {
        List<ScheduledNotificationInfo> scheduledNotifications = loadScheduledNotifications(context);

        if (scheduledNotifications.isEmpty()) {
            return;
        }

        NotificationScheduler scheduler = new NotificationScheduler(context);
        long currentTime = System.currentTimeMillis();

        for (ScheduledNotificationInfo info : scheduledNotifications) {
            // Apenas reagendar se ainda não passou
            if (info.scheduledTime > currentTime) {
                NotificationDTO notification = info.toNotificationDTO();
                scheduler.scheduleNotification(notification);
            }
        }
    }

    // ========== Métodos de persistência de notificações agendadas ==========

    /**
     * Salva informação de notificações agendadas para reagendar após reboot
     */
    public static void saveScheduledNotification(Context context, NotificationDTO notification) {
        List<ScheduledNotificationInfo> scheduled = loadScheduledNotifications(context);

        ScheduledNotificationInfo info = new ScheduledNotificationInfo(notification);
        scheduled.add(info);

        SharedPreferences prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE);
        Gson gson = new Gson();
        String json = gson.toJson(scheduled);
        prefs.edit().putString(KEY_SCHEDULED, json).apply();
    }

    /**
     * Remove notificação agendada da lista (quando for cancelada ou executada)
     */
    public static void removeScheduledNotification(Context context, int notificationId) {
        List<ScheduledNotificationInfo> scheduled = loadScheduledNotifications(context);
        scheduled.removeIf(info -> info.id == notificationId);

        SharedPreferences prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE);
        Gson gson = new Gson();
        String json = gson.toJson(scheduled);
        prefs.edit().putString(KEY_SCHEDULED, json).apply();
    }

    private static List<ScheduledNotificationInfo> loadScheduledNotifications(Context context) {
        SharedPreferences prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE);
        String json = prefs.getString(KEY_SCHEDULED, "[]");

        Gson gson = new Gson();
        Type listType = new TypeToken<List<ScheduledNotificationInfo>>(){}.getType();
        List<ScheduledNotificationInfo> notifications = gson.fromJson(json, listType);

        return notifications != null ? notifications : new ArrayList<>();
    }

    // ========== Classe auxiliar para serialização ==========

    private static class ScheduledNotificationInfo {
        int id;
        String title;
        String message;
        long scheduledTime;
        String type;

        ScheduledNotificationInfo(NotificationDTO notification) {
            this.id = notification.getId();
            this.title = notification.getTitle();
            this.message = notification.getMessage();
            this.scheduledTime = notification.getTimestamp().getTime();
            this.type = notification.getType().name();
        }

        NotificationDTO toNotificationDTO() {
            NotificationDTO.NotificationType notificationType;
            try {
                notificationType = NotificationDTO.NotificationType.valueOf(type);
            } catch (Exception e) {
                notificationType = NotificationDTO.NotificationType.GENERAL;
            }

            return new NotificationDTO(
                    id,
                    title,
                    message,
                    new Date(scheduledTime),
                    false,
                    notificationType
            );
        }
    }
}