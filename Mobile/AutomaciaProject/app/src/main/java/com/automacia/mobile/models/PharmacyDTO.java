package com.automacia.mobile.models;

import java.io.Serializable;

public class PharmacyDTO implements Serializable {
    private String id;
    private String name;
    private String address;
    private double latitude;
    private double longitude;
    private double distanceInKm;
    private boolean isOpen;
    private boolean is24Hours;
    private String openingHours;
    private String closingTime;
    private String phone;
    private String website;

    // Construtor vazio
    public PharmacyDTO() {
    }

    // Construtor completo
    public PharmacyDTO(String id, String name, String address, double latitude,
                       double longitude, String phone) {
        this.id = id;
        this.name = name;
        this.address = address;
        this.latitude = latitude;
        this.longitude = longitude;
        this.phone = phone;
        this.isOpen = false;
        this.is24Hours = false;
    }

    // Getters e Setters
    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public double getLatitude() {
        return latitude;
    }

    public void setLatitude(double latitude) {
        this.latitude = latitude;
    }

    public double getLongitude() {
        return longitude;
    }

    public void setLongitude(double longitude) {
        this.longitude = longitude;
    }

    public double getDistanceInKm() {
        return distanceInKm;
    }

    public void setDistanceInKm(double distanceInKm) {
        this.distanceInKm = distanceInKm;
    }

    public boolean isOpen() {
        return isOpen;
    }

    public void setOpen(boolean open) {
        isOpen = open;
    }

    public boolean is24Hours() {
        return is24Hours;
    }

    public void set24Hours(boolean is24Hours) {
        this.is24Hours = is24Hours;
    }

    public String getOpeningHours() {
        return openingHours;
    }

    public void setOpeningHours(String openingHours) {
        this.openingHours = openingHours;
    }

    public String getClosingTime() {
        return closingTime;
    }

    public void setClosingTime(String closingTime) {
        this.closingTime = closingTime;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public String getWebsite() {
        return website;
    }

    public void setWebsite(String website) {
        this.website = website;
    }

    // Método auxiliar para formatar a distância
    public String getFormattedDistance() {
        if (distanceInKm < 1.0) {
            return String.format("%.0f m", distanceInKm * 1000);
        } else {
            return String.format("%.1f km", distanceInKm);
        }
    }

    // Método auxiliar para obter texto do status
    public String getStatusText() {
        if (is24Hours) {
            return "Aberto 24h";
        } else if (isOpen) {
            return "Aberto";
        } else {
            return "Fechado";
        }
    }

    // Método auxiliar para obter horário formatado
    public String getHoursInfo() {
        if (is24Hours) {
            return "• 24 horas";
        } else if (isOpen && closingTime != null && !closingTime.isEmpty()) {
            return "• Fecha às " + closingTime;
        } else if (!isOpen && openingHours != null && !openingHours.isEmpty()) {
            return "• Abre às " + openingHours;
        }
        return "";
    }

    @Override
    public String toString() {
        return "PharmacyDTO{" +
                "id='" + id + '\'' +
                ", name='" + name + '\'' +
                ", address='" + address + '\'' +
                ", latitude=" + latitude +
                ", longitude=" + longitude +
                ", distanceInKm=" + distanceInKm +
                ", isOpen=" + isOpen +
                ", is24Hours=" + is24Hours +
                '}';
    }
}