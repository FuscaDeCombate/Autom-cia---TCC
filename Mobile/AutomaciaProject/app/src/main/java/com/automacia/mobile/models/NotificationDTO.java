package com.automacia.mobile.models;

import java.util.Date;

public class NotificationDTO {
    public enum NotificationType {
        PRESCRIPTION_EXPIRING,
        NEW_PRESCRIPTION,
        MEDICATION_REMINDER,
        PHARMACY_READY,
        SYSTEM_UPDATE,
        APPOINTMENT_REMINDER,
        GENERAL
    }

    private int id;
    private String title;
    private String message;
    private Date timestamp;
    private boolean isRead;
    private NotificationType type;
    private String iconResource;
    private String backgroundColorResource;
    private String iconTintResource;

    public NotificationDTO() {}

    public NotificationDTO(int id, String title, String message, Date timestamp,
                           boolean isRead, NotificationType type) {
        this.id = id;
        this.title = title;
        this.message = message;
        this.timestamp = timestamp;
        this.isRead = isRead;
        this.type = type;
        setIconAndColors();
    }

    private void setIconAndColors() {
        switch (type) {
            case PRESCRIPTION_EXPIRING:
                iconResource = "ic_warning";
                backgroundColorResource = "red_light";
                iconTintResource = "red";
                break;
            case NEW_PRESCRIPTION:
                iconResource = "ic_description";
                backgroundColorResource = "primary_light";
                iconTintResource = "primary";
                break;
            case MEDICATION_REMINDER:
                iconResource = "ic_pharmacy";
                backgroundColorResource = "green_light";
                iconTintResource = "green";
                break;
            case PHARMACY_READY:
                iconResource = "ic_store";
                backgroundColorResource = "blue_light";
                iconTintResource = "blue";
                break;
            case SYSTEM_UPDATE:
                iconResource = "ic_system_update";
                backgroundColorResource = "gray_light";
                iconTintResource = "gray";
                break;
            case APPOINTMENT_REMINDER:
                iconResource = "ic_calendar";
                backgroundColorResource = "orange_light";
                iconTintResource = "orange";
                break;
            default:
                iconResource = "ic_notifications";
                backgroundColorResource = "gray_light";
                iconTintResource = "gray";
                break;
        }
    }

    // Getters and Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }

    public Date getTimestamp() { return timestamp; }
    public void setTimestamp(Date timestamp) { this.timestamp = timestamp; }

    public boolean isRead() { return isRead; }
    public void setRead(boolean read) { isRead = read; }

    public NotificationType getType() { return type; }
    public void setType(NotificationType type) {
        this.type = type;
        setIconAndColors();
    }

    public String getIconResource() { return iconResource; }
    public String getBackgroundColorResource() { return backgroundColorResource; }
    public String getIconTintResource() { return iconTintResource; }
}