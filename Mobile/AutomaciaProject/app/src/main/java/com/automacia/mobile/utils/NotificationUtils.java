package com.automacia.mobile.utils;

import com.automacia.mobile.models.Notification;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Collections;
import java.util.Comparator;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class NotificationUtils {

    public enum DateSection {
        TODAY("Hoje"),
        YESTERDAY("Ontem"),
        THIS_WEEK("Esta Semana"),
        OLDER("Anteriores");

        private final String displayName;

        DateSection(String displayName) {
            this.displayName = displayName;
        }

        public String getDisplayName() {
            return displayName;
        }
    }

    public static Map<DateSection, List<Notification>> groupNotificationsByDate(List<Notification> notifications) {
        Map<DateSection, List<Notification>> groupedNotifications = new HashMap<>();

        // Inicializar listas vazias
        for (DateSection section : DateSection.values()) {
            groupedNotifications.put(section, new ArrayList<>());
        }

        Calendar now = Calendar.getInstance();
        Calendar today = Calendar.getInstance();
        today.set(Calendar.HOUR_OF_DAY, 0);
        today.set(Calendar.MINUTE, 0);
        today.set(Calendar.SECOND, 0);
        today.set(Calendar.MILLISECOND, 0);

        Calendar yesterday = Calendar.getInstance();
        yesterday.add(Calendar.DAY_OF_YEAR, -1);
        yesterday.set(Calendar.HOUR_OF_DAY, 0);
        yesterday.set(Calendar.MINUTE, 0);
        yesterday.set(Calendar.SECOND, 0);
        yesterday.set(Calendar.MILLISECOND, 0);

        Calendar weekStart = Calendar.getInstance();
        weekStart.add(Calendar.DAY_OF_YEAR, -7);
        weekStart.set(Calendar.HOUR_OF_DAY, 0);
        weekStart.set(Calendar.MINUTE, 0);
        weekStart.set(Calendar.SECOND, 0);
        weekStart.set(Calendar.MILLISECOND, 0);

        for (Notification notification : notifications) {
            Date notificationDate = notification.getTimestamp();
            Calendar notificationCal = Calendar.getInstance();
            notificationCal.setTime(notificationDate);

            if (isSameDay(notificationCal, today)) {
                groupedNotifications.get(DateSection.TODAY).add(notification);
            } else if (isSameDay(notificationCal, yesterday)) {
                groupedNotifications.get(DateSection.YESTERDAY).add(notification);
            } else if (notificationDate.after(weekStart.getTime())) {
                groupedNotifications.get(DateSection.THIS_WEEK).add(notification);
            } else {
                groupedNotifications.get(DateSection.OLDER).add(notification);
            }
        }

        // Ordenar notificações dentro de cada seção por timestamp decrescente
        for (List<Notification> sectionNotifications : groupedNotifications.values()) {
            Collections.sort(sectionNotifications, new Comparator<Notification>() {
                @Override
                public int compare(Notification n1, Notification n2) {
                    return n2.getTimestamp().compareTo(n1.getTimestamp());
                }
            });
        }

        return groupedNotifications;
    }

    private static boolean isSameDay(Calendar cal1, Calendar cal2) {
        return cal1.get(Calendar.YEAR) == cal2.get(Calendar.YEAR) &&
                cal1.get(Calendar.DAY_OF_YEAR) == cal2.get(Calendar.DAY_OF_YEAR);
    }

    public static List<Notification> generateSampleNotifications() {
        List<Notification> notifications = new ArrayList<>();

        Calendar now = Calendar.getInstance();

        // Notificações de hoje
        Calendar today1 = (Calendar) now.clone();
        today1.set(Calendar.HOUR_OF_DAY, 14);
        today1.set(Calendar.MINUTE, 30);
        notifications.add(new Notification(1, "Receita vencendo",
                "Sua receita de Losartana vence em 2 dias. Renove antes do vencimento.",
                today1.getTime(), false, Notification.NotificationType.PRESCRIPTION_EXPIRING));

        Calendar today2 = (Calendar) now.clone();
        today2.set(Calendar.HOUR_OF_DAY, 10);
        today2.set(Calendar.MINUTE, 15);
        notifications.add(new Notification(2, "Nova receita recebida",
                "Dr. Silva enviou uma nova receita para Omeprazol 20mg.",
                today2.getTime(), false, Notification.NotificationType.NEW_PRESCRIPTION));

        // Notificações de ontem
        Calendar yesterday1 = (Calendar) now.clone();
        yesterday1.add(Calendar.DAY_OF_YEAR, -1);
        yesterday1.set(Calendar.HOUR_OF_DAY, 8);
        yesterday1.set(Calendar.MINUTE, 0);
        notifications.add(new Notification(3, "Lembrete de medicação",
                "Hora de tomar Losartana 50mg - Pressão arterial.",
                yesterday1.getTime(), true, Notification.NotificationType.MEDICATION_REMINDER));

        Calendar yesterday2 = (Calendar) now.clone();
        yesterday2.add(Calendar.DAY_OF_YEAR, -1);
        yesterday2.set(Calendar.HOUR_OF_DAY, 16);
        yesterday2.set(Calendar.MINUTE, 45);
        notifications.add(new Notification(4, "Medicamento disponível",
                "Farmácia Popular: Seu medicamento Omeprazol está disponível para retirada.",
                yesterday2.getTime(), true, Notification.NotificationType.PHARMACY_READY));

        // Notificações desta semana
        Calendar thisWeek = (Calendar) now.clone();
        thisWeek.add(Calendar.DAY_OF_YEAR, -3);
        thisWeek.set(Calendar.HOUR_OF_DAY, 9);
        thisWeek.set(Calendar.MINUTE, 0);
        notifications.add(new Notification(5, "Atualização do sistema",
                "Nova versão 0.45 disponível com melhorias de segurança e performance.",
                thisWeek.getTime(), true, Notification.NotificationType.SYSTEM_UPDATE));

        Calendar thisWeek2 = (Calendar) now.clone();
        thisWeek2.add(Calendar.DAY_OF_YEAR, -4);
        thisWeek2.set(Calendar.HOUR_OF_DAY, 15);
        thisWeek2.set(Calendar.MINUTE, 30);
        notifications.add(new Notification(6, "Consulta agendada",
                "Consulta com Dr. Santos agendada para próxima terça-feira às 14:00.",
                thisWeek2.getTime(), true, Notification.NotificationType.APPOINTMENT_REMINDER));

        // Notificações mais antigas
        Calendar older = (Calendar) now.clone();
        older.add(Calendar.DAY_OF_YEAR, -10);
        older.set(Calendar.HOUR_OF_DAY, 11);
        older.set(Calendar.MINUTE, 20);
        notifications.add(new Notification(7, "Exames prontos",
                "Seus exames de sangue estão prontos para retirada no laboratório.",
                older.getTime(), true, Notification.NotificationType.GENERAL));

        return notifications;
    }

    public static int getUnreadCount(List<Notification> notifications) {
        int count = 0;
        for (Notification notification : notifications) {
            if (!notification.isRead()) {
                count++;
            }
        }
        return count;
    }
}