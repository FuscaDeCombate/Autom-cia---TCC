package com.automacia.mobile.receivers;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import com.automacia.mobile.models.NotificationDTO;
import com.automacia.mobile.storage.NotificationStorage;
import com.automacia.mobile.utils.NotificationScheduler;
import java.util.Date;

/**
 * Receiver que captura notificações agendadas e as processa
 */
public class NotificationReceiver extends BroadcastReceiver {

    @Override
    public void onReceive(Context context, Intent intent) {
        if (intent == null || intent.getAction() == null) {
            return;
        }

        if ("com.automacia.mobile.SHOW_NOTIFICATION".equals(intent.getAction())) {
            handleScheduledNotification(context, intent);
        }
    }

    private void handleScheduledNotification(Context context, Intent intent) {
        // Extrair dados da notificação
        int notificationId = intent.getIntExtra("notification_id", -1);
        String title = intent.getStringExtra("notification_title");
        String message = intent.getStringExtra("notification_message");
        String typeName = intent.getStringExtra("notification_type");
        long timestamp = intent.getLongExtra("notification_timestamp", System.currentTimeMillis());

        if (notificationId == -1 || title == null || message == null) {
            return;
        }

        // Converter tipo
        NotificationDTO.NotificationType type;
        try {
            type = NotificationDTO.NotificationType.valueOf(typeName);
        } catch (Exception e) {
            type = NotificationDTO.NotificationType.GENERAL;
        }

        // Criar objeto NotificationDTO
        NotificationDTO notification = new NotificationDTO(
                notificationId,
                title,
                message,
                new Date(timestamp),
                false, // não lida
                type
        );

        // Salvar no storage (agora a notificação aparece no fragment)
        NotificationStorage storage = new NotificationStorage(context);
        storage.addNotification(notification);

        // Mostrar no sistema Android
        NotificationScheduler scheduler = new NotificationScheduler(context);
        scheduler.showSystemNotification(notification);

        // Remover da lista de agendadas (já foi disparada)
        com.automacia.mobile.receivers.BootReceiver.removeScheduledNotification(context, notificationId);
    }
}