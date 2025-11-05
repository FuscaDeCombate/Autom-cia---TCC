package com.automacia.mobile.utils;

import android.app.AlarmManager;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.os.Build;
import androidx.core.app.NotificationCompat;
import androidx.core.app.NotificationManagerCompat;
import com.automacia.mobile.R;
import com.automacia.mobile.models.NotificationDTO;
import com.automacia.mobile.receivers.NotificationReceiver;

/**
 * Responsável por agendar e mostrar notificações do sistema Android
 */
public class NotificationScheduler {

    private static final String CHANNEL_ID = "automacia_notifications";
    private static final String CHANNEL_NAME = "Notificações Automacia";
    private static final String CHANNEL_DESCRIPTION = "Lembretes de medicamentos, receitas e consultas";

    private final Context context;
    private final AlarmManager alarmManager;

    public NotificationScheduler(Context context) {
        this.context = context.getApplicationContext();
        this.alarmManager = (AlarmManager) context.getSystemService(Context.ALARM_SERVICE);
        createNotificationChannel();
    }

    /**
     * Cria canal de notificações (necessário Android 8+)
     */
    private void createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationChannel channel = new NotificationChannel(
                    CHANNEL_ID,
                    CHANNEL_NAME,
                    NotificationManager.IMPORTANCE_HIGH
            );
            channel.setDescription(CHANNEL_DESCRIPTION);
            channel.enableVibration(true);
            channel.enableLights(true);

            NotificationManager manager = context.getSystemService(NotificationManager.class);
            if (manager != null) {
                manager.createNotificationChannel(channel);
            }
        }
    }

    /**
     * Agenda uma notificação para ser disparada no futuro
     */
    public void scheduleNotification(NotificationDTO notification) {
        long scheduledTimeMillis = notification.getTimestamp().getTime();
        long currentTimeMillis = System.currentTimeMillis();

        // Não agendar se já passou
        if (scheduledTimeMillis <= currentTimeMillis) {
            showSystemNotification(notification);
            return;
        }

        Intent intent = new Intent(context, NotificationReceiver.class);
        intent.setAction("com.automacia.mobile.SHOW_NOTIFICATION");
        intent.putExtra("notification_id", notification.getId());
        intent.putExtra("notification_title", notification.getTitle());
        intent.putExtra("notification_message", notification.getMessage());
        intent.putExtra("notification_type", notification.getType().name());
        intent.putExtra("notification_timestamp", scheduledTimeMillis);

        PendingIntent pendingIntent = PendingIntent.getBroadcast(
                context,
                notification.getId(),
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE
        );

        // Agendar alarme exato
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            alarmManager.setExactAndAllowWhileIdle(
                    AlarmManager.RTC_WAKEUP,
                    scheduledTimeMillis,
                    pendingIntent
            );
        } else {
            alarmManager.setExact(
                    AlarmManager.RTC_WAKEUP,
                    scheduledTimeMillis,
                    pendingIntent
            );
        }

        // Salvar para reagendar após reboot
        com.automacia.mobile.receivers.BootReceiver.saveScheduledNotification(context, notification);
    }

    /**
     * Mostra notificação no sistema Android AGORA
     */
    public void showSystemNotification(NotificationDTO notification) {
        NotificationCompat.Builder builder = new NotificationCompat.Builder(context, CHANNEL_ID)
                .setSmallIcon(getNotificationIcon(notification.getType()))
                .setContentTitle(notification.getTitle())
                .setContentText(notification.getMessage())
                .setStyle(new NotificationCompat.BigTextStyle().bigText(notification.getMessage()))
                .setPriority(NotificationCompat.PRIORITY_HIGH)
                .setAutoCancel(true)
                .setVibrate(new long[]{0, 500, 200, 500})
                .setColor(context.getColor(getNotificationColor(notification.getType())));

        // Intent para abrir o app ao clicar na notificação
        Intent intent = context.getPackageManager().getLaunchIntentForPackage(context.getPackageName());
        if (intent != null) {
            intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
            intent.putExtra("notification_id", notification.getId());
            intent.putExtra("open_notifications", true);

            PendingIntent contentIntent = PendingIntent.getActivity(
                    context,
                    notification.getId(),
                    intent,
                    PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE
            );

            builder.setContentIntent(contentIntent);
        }

        NotificationManagerCompat notificationManager = NotificationManagerCompat.from(context);

        try {
            notificationManager.notify(notification.getId(), builder.build());
        } catch (SecurityException e) {
            e.printStackTrace();
            // Usuário negou permissão de notificação
        }
    }

    /**
     * Cancela uma notificação agendada
     */
    public void cancelScheduledNotification(int notificationId) {
        Intent intent = new Intent(context, NotificationReceiver.class);
        intent.setAction("com.automacia.mobile.SHOW_NOTIFICATION");

        PendingIntent pendingIntent = PendingIntent.getBroadcast(
                context,
                notificationId,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE
        );

        alarmManager.cancel(pendingIntent);

        // Remover do sistema também
        NotificationManagerCompat notificationManager = NotificationManagerCompat.from(context);
        notificationManager.cancel(notificationId);
    }

    /**
     * Cancela todas as notificações agendadas
     */
    public void cancelAllScheduledNotifications() {
        // Cancelar notificações visíveis
        NotificationManagerCompat notificationManager = NotificationManagerCompat.from(context);
        notificationManager.cancelAll();
    }

    // ========== Métodos auxiliares ==========

    private int getNotificationIcon(NotificationDTO.NotificationType type) {
        switch (type) {
            case PRESCRIPTION_EXPIRING:
                return R.drawable.ic_warning;
            case NEW_PRESCRIPTION:
                return R.drawable.ic_description;
            case MEDICATION_REMINDER:
                return R.drawable.ic_pharmacy;
            case PHARMACY_READY:
                return R.drawable.ic_store;
            case SYSTEM_UPDATE:
                return R.drawable.ic_system_update;
            case APPOINTMENT_REMINDER:
                return R.drawable.ic_calendar;
            default:
                return R.drawable.ic_notifications;
        }
    }

    private int getNotificationColor(NotificationDTO.NotificationType type) {
        switch (type) {
            case PRESCRIPTION_EXPIRING:
                return R.color.red;
            case NEW_PRESCRIPTION:
                return R.color.primary;
            case MEDICATION_REMINDER:
                return R.color.green;
            case PHARMACY_READY:
                return R.color.blue;
            case SYSTEM_UPDATE:
                return R.color.gray;
            case APPOINTMENT_REMINDER:
                return R.color.orange;
            default:
                return R.color.gray;
        }
    }
}