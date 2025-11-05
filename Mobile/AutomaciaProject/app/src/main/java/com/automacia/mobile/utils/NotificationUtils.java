package com.automacia.mobile.utils;

import com.automacia.mobile.models.NotificationDTO;
import com.automacia.mobile.models.NotificationItem;
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

    /**
     * Agrupa notificações por data (Hoje, Ontem, Esta Semana, Anteriores)
     */
    public static Map<DateSection, List<NotificationDTO>> groupNotificationsByDate(
            List<NotificationDTO> notifications) {
        Map<DateSection, List<NotificationDTO>> groupedNotifications = new HashMap<>();

        // Inicializar listas vazias
        for (DateSection section : DateSection.values()) {
            groupedNotifications.put(section, new ArrayList<>());
        }

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

        for (NotificationDTO notification : notifications) {
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
        for (List<NotificationDTO> sectionNotifications : groupedNotifications.values()) {
            Collections.sort(sectionNotifications, new Comparator<NotificationDTO>() {
                @Override
                public int compare(NotificationDTO n1, NotificationDTO n2) {
                    return n2.getTimestamp().compareTo(n1.getTimestamp());
                }
            });
        }

        return groupedNotifications;
    }

    /**
     * Converte mapa de notificações agrupadas em lista plana para RecyclerView
     * Formato: [HEADER, ITEM, ITEM, HEADER, ITEM...]
     */
    public static List<NotificationItem> convertToFlatList(
            Map<DateSection, List<NotificationDTO>> groupedNotifications) {
        List<NotificationItem> flatList = new ArrayList<>();

        // Ordem de exibição das seções
        DateSection[] sections = {
                DateSection.TODAY,
                DateSection.YESTERDAY,
                DateSection.THIS_WEEK,
                DateSection.OLDER
        };

        for (DateSection section : sections) {
            List<NotificationDTO> sectionNotifications = groupedNotifications.get(section);

            // Apenas adicionar seção se houver notificações
            if (sectionNotifications != null && !sectionNotifications.isEmpty()) {
                // Adicionar header
                flatList.add(NotificationItem.createHeader(section.getDisplayName()));

                // Adicionar notificações da seção
                for (NotificationDTO notification : sectionNotifications) {
                    flatList.add(NotificationItem.createNotification(notification));
                }
            }
        }

        return flatList;
    }

    /**
     * Retorna contagem de notificações não lidas
     */
    public static int getUnreadCount(List<NotificationDTO> notifications) {
        int count = 0;
        for (NotificationDTO notification : notifications) {
            if (!notification.isRead()) {
                count++;
            }
        }
        return count;
    }

    private static boolean isSameDay(Calendar cal1, Calendar cal2) {
        return cal1.get(Calendar.YEAR) == cal2.get(Calendar.YEAR) &&
                cal1.get(Calendar.DAY_OF_YEAR) == cal2.get(Calendar.DAY_OF_YEAR);
    }

    // ========== MÉTODOS DE TESTE (remover em produção) ==========

    /**
     * Gera notificações de exemplo para testes
     * REMOVER EM PRODUÇÃO - usar apenas durante desenvolvimento
     */
    public static List<NotificationDTO> generateSampleNotifications() {
        List<NotificationDTO> notifications = new ArrayList<>();
        Calendar now = Calendar.getInstance();

        // Notificações de hoje
        Calendar today1 = (Calendar) now.clone();
        today1.set(Calendar.HOUR_OF_DAY, 14);
        today1.set(Calendar.MINUTE, 30);
        notifications.add(new NotificationDTO(1, "Receita vencendo",
                "Sua receita de Losartana vence em 2 dias. Renove antes do vencimento.",
                today1.getTime(), false, NotificationDTO.NotificationType.PRESCRIPTION_EXPIRING));

        Calendar today2 = (Calendar) now.clone();
        today2.set(Calendar.HOUR_OF_DAY, 10);
        today2.set(Calendar.MINUTE, 15);
        notifications.add(new NotificationDTO(2, "Nova receita recebida",
                "Dr. Silva enviou uma nova receita para Omeprazol 20mg.",
                today2.getTime(), false, NotificationDTO.NotificationType.NEW_PRESCRIPTION));

        // Notificações de ontem
        Calendar yesterday1 = (Calendar) now.clone();
        yesterday1.add(Calendar.DAY_OF_YEAR, -1);
        yesterday1.set(Calendar.HOUR_OF_DAY, 8);
        yesterday1.set(Calendar.MINUTE, 0);
        notifications.add(new NotificationDTO(3, "Lembrete de medicação",
                "Hora de tomar Losartana 50mg - Pressão arterial.",
                yesterday1.getTime(), true, NotificationDTO.NotificationType.MEDICATION_REMINDER));

        Calendar yesterday2 = (Calendar) now.clone();
        yesterday2.add(Calendar.DAY_OF_YEAR, -1);
        yesterday2.set(Calendar.HOUR_OF_DAY, 16);
        yesterday2.set(Calendar.MINUTE, 45);
        notifications.add(new NotificationDTO(4, "Medicamento disponível",
                "Farmácia Popular: Seu medicamento Omeprazol está disponível para retirada.",
                yesterday2.getTime(), true, NotificationDTO.NotificationType.PHARMACY_READY));

        // Notificações desta semana
        Calendar thisWeek = (Calendar) now.clone();
        thisWeek.add(Calendar.DAY_OF_YEAR, -3);
        thisWeek.set(Calendar.HOUR_OF_DAY, 9);
        thisWeek.set(Calendar.MINUTE, 0);
        notifications.add(new NotificationDTO(5, "Atualização do sistema",
                "Nova versão 0.45 disponível com melhorias de segurança e performance.",
                thisWeek.getTime(), true, NotificationDTO.NotificationType.SYSTEM_UPDATE));

        Calendar thisWeek2 = (Calendar) now.clone();
        thisWeek2.add(Calendar.DAY_OF_YEAR, -4);
        thisWeek2.set(Calendar.HOUR_OF_DAY, 15);
        thisWeek2.set(Calendar.MINUTE, 30);
        notifications.add(new NotificationDTO(6, "Consulta agendada",
                "Consulta com Dr. Santos agendada para próxima terça-feira às 14:00.",
                thisWeek2.getTime(), true, NotificationDTO.NotificationType.APPOINTMENT_REMINDER));

        // Notificações mais antigas
        Calendar older = (Calendar) now.clone();
        older.add(Calendar.DAY_OF_YEAR, -10);
        older.set(Calendar.HOUR_OF_DAY, 11);
        older.set(Calendar.MINUTE, 20);
        notifications.add(new NotificationDTO(7, "Exames prontos",
                "Seus exames de sangue estão prontos para retirada no laboratório.",
                older.getTime(), true, NotificationDTO.NotificationType.GENERAL));

        return notifications;
    }
}