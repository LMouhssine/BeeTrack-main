package com.rucheconnectee.model;

import com.fasterxml.jackson.annotation.JsonProperty;
import java.time.LocalDateTime;

/**
 * Modèle représentant les données collectées par les capteurs IoT d'une ruche.
 * Correspond aux données envoyées par l'ESP32.
 */
public class DonneesCapteur {
    
    private String id;
    
    @JsonProperty("ruche_id")
    private String rucheId;
    
    @JsonProperty("timestamp")
    private LocalDateTime timestamp;
    
    @JsonProperty("temperature")
    private Double temperature;
    
    @JsonProperty("humidity")
    private Double humidity;
    
    @JsonProperty("couvercle_ouvert")
    private Boolean couvercleOuvert;
    
    @JsonProperty("batterie")
    private Integer batterie;
    
    @JsonProperty("signal_qualite")
    private Integer signalQualite;
    
    @JsonProperty("erreur")
    private String erreur;

    @JsonProperty("humidite")
    private Double humidite;

    @JsonProperty("poids")
    private Double poids;

    // Constructors
    public DonneesCapteur() {}

    // Getters and Setters
    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getRucheId() {
        return rucheId;
    }

    public void setRucheId(String rucheId) {
        this.rucheId = rucheId;
    }

    public LocalDateTime getTimestamp() {
        return timestamp;
    }

    public void setTimestamp(LocalDateTime timestamp) {
        this.timestamp = timestamp;
    }

    public Double getTemperature() {
        return temperature;
    }

    public void setTemperature(Double temperature) {
        this.temperature = temperature;
    }

    public Double getHumidity() {
        return humidity;
    }

    public void setHumidity(Double humidity) {
        this.humidity = humidity;
    }

    public Boolean getCouvercleOuvert() {
        return couvercleOuvert;
    }

    public void setCouvercleOuvert(Boolean couvercleOuvert) {
        this.couvercleOuvert = couvercleOuvert;
    }

    public Integer getBatterie() {
        return batterie;
    }

    public void setBatterie(Integer batterie) {
        this.batterie = batterie;
    }

    public Integer getSignalQualite() {
        return signalQualite;
    }

    public void setSignalQualite(Integer signalQualite) {
        this.signalQualite = signalQualite;
    }

    public String getErreur() {
        return erreur;
    }

    public void setErreur(String erreur) {
        this.erreur = erreur;
    }

    public Double getHumidite() {
        return humidite;
    }

    public void setHumidite(Double humidite) {
        this.humidite = humidite;
    }

    public Double getPoids() {
        return poids;
    }

    public void setPoids(Double poids) {
        this.poids = poids;
    }
} 