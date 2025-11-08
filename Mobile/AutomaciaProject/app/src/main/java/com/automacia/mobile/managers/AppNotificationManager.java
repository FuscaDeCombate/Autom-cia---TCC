package com.automacia.mobile.managers;

import android.content.Context;
import com.automacia.mobile.models.NotificationDTO;
import com.automacia.mobile.storage.NotificationStorage;
import com.automacia.mobile.utils.NotificationScheduler;
import java.util.Date;
import java.util.concurrent.atomic.AtomicInteger;

/**
 * Manager central para criar e gerenciar notificações no app
 * USO:
 * NotificationManager.getInstance(context).createNotification(...)
 */
public class AppNotificationManager {

    private static AppNotificationManager instance;
    private final Context context;
    private final NotificationStorage storage;
    private final NotificationScheduler scheduler;
    private final AtomicInteger notificationIdGenerator;

    private AppNotificationManager(Context context) {
        this.context = context.getApplicationContext();
        this.storage = new NotificationStorage(this.context);
        this.scheduler = new NotificationScheduler(this.context);
        this.notificationIdGenerator = new AtomicInteger(getLastNotificationId());
    }

    public static synchronized AppNotificationManager getInstance(Context context) {
        if (instance == null) {
            instance = new AppNotificationManager(context);
        }
        return instance;
    }

    /**
     * Cria uma notificação IMEDIATA (aparece agora no sistema e no fragment)
     */
    public NotificationDTO createImmediateNotification(
            String title,
            String message,
            NotificationDTO.NotificationType type) {

        int id = generateNotificationId();
        Date now = new Date();

        NotificationDTO notification = new NotificationDTO(
                id, title, message, now, false, type
        );

        // Salvar no storage
        storage.addNotification(notification);

        // Mostrar no sistema Android
        scheduler.showSystemNotification(notification);

        return notification;
    }

    /**
     * Agenda uma notificação para o FUTURO (será mostrada na data/hora especificada)
     */
    public NotificationDTO scheduleNotification(
            String title,
            String message,
            Date scheduledTime,
            NotificationDTO.NotificationType type) {

        int id = generateNotificationId();

        NotificationDTO notification = new NotificationDTO(
                id, title, message, scheduledTime, false, type
        );

        // Agendar no AlarmManager
        scheduler.scheduleNotification(notification);

        // NÃO salva no storage ainda - será salvo quando a notificação disparar

        return notification;
    }

    /**
     * Cria notificação de RECEITA VENCENDO
     */
    public NotificationDTO notifyPrescriptionExpiring(String medicationName, int daysRemaining) {
        return createImmediateNotification(
                "Receita vencendo",
                String.format("Sua receita de %s vence em %d dias. Renove antes do vencimento.",
                        medicationName, daysRemaining),
                NotificationDTO.NotificationType.PRESCRIPTION_EXPIRING
        );
    }

    /**
     * Cria notificação de NOVA RECEITA
     */
    public NotificationDTO notifyNewPrescription(String doctorName, String medicationName) {
        return createImmediateNotification(
                "Nova receita recebida",
                String.format("Dr. %s enviou uma nova receita para %s.", doctorName, medicationName),
                NotificationDTO.NotificationType.NEW_PRESCRIPTION
        );
    }

    /**
     * Agenda LEMBRETE DE MEDICAÇÃO
     */
    public NotificationDTO scheduleMedicationReminder(
            String medicationName,
            String dosage,
            Date reminderTime) {

        return scheduleNotification(
                "Lembrete de medicação",
                String.format("Hora de tomar %s - %s.", medicationName, dosage),
                reminderTime,
                NotificationDTO.NotificationType.MEDICATION_REMINDER
        );
    }

    /**
     * Cria notificação de MEDICAMENTO DISPONÍVEL NA FARMÁCIA
     */
    public NotificationDTO notifyPharmacyReady(String pharmacyName, String medicationName) {
        return createImmediateNotification(
                "Medicamento disponível",
                String.format("%s: Seu medicamento %s está disponível para retirada.",
                        pharmacyName, medicationName),
                NotificationDTO.NotificationType.PHARMACY_READY
        );
    }

    /**
     * Agenda LEMBRETE DE CONSULTA
     */
    public NotificationDTO scheduleAppointmentReminder(
            String doctorName,
            Date appointmentTime,
            int hoursBeforeReminder) {

        // Calcular tempo do lembrete (ex: 24h antes da consulta)
        long reminderTimestamp = appointmentTime.getTime() - (hoursBeforeReminder * 60 * 60 * 1000L);
        Date reminderTime = new Date(reminderTimestamp);

        return scheduleNotification(
                "Lembrete de consulta",
                String.format("Consulta com Dr. %s agendada para amanhã.", doctorName),
                reminderTime,
                NotificationDTO.NotificationType.APPOINTMENT_REMINDER
        );
    }

    /**
     * Cria notificação de ATUALIZAÇÃO DO SISTEMA
     */
    public NotificationDTO notifySystemUpdate(String version, String changes) {
        return createImmediateNotification(
                "Atualização do sistema",
                String.format("Nova versão %s disponível. %s", version, changes),
                NotificationDTO.NotificationType.SYSTEM_UPDATE
        );
    }

    /**
     * Cria notificação GENÉRICA
     */
    public NotificationDTO notifyGeneral(String title, String message) {
        return createImmediateNotification(title, message, NotificationDTO.NotificationType.GENERAL);
    }

    /**
     * Cria notificação de NOVA MENSAGEM
     */
    public NotificationDTO notifyNewMessage(String senderName, String messagePreview) {
        return createImmediateNotification(
                "Nova mensagem de " + senderName,
                messagePreview,
                NotificationDTO.NotificationType.NEW_MESSAGE
        );
    }

    /**
     * Cancela uma notificação agendada
     */
    public void cancelScheduledNotification(int notificationId) {
        scheduler.cancelScheduledNotification(notificationId);
    }

    /**
     * Marca notificação como lida
     */
    public void markAsRead(int notificationId) {
        storage.markAsRead(notificationId);
    }

    /**
     * Remove uma notificação
     */
    public void removeNotification(int notificationId) {
        storage.removeNotification(notificationId);
        scheduler.cancelScheduledNotification(notificationId);
    }

    // ========== Métodos auxiliares ==========

    private int generateNotificationId() {
        return notificationIdGenerator.incrementAndGet();
    }

    private int getLastNotificationId() {
        // Buscar maior ID do storage para continuar sequência
        int maxId = 0;
        for (NotificationDTO notification : storage.loadNotifications()) {
            if (notification.getId() > maxId) {
                maxId = notification.getId();
            }
        }
        return maxId;
    }
}