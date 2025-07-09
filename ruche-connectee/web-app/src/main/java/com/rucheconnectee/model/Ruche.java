package com.rucheconnectee.model;

import com.fasterxml.jackson.annotation.JsonProperty;
import java.time.LocalDateTime;

/**
 * Modèle représentant une ruche connectée avec ses capteurs IoT.
 * Correspond à la collection 'ruches' dans Firebase.
 */
public class Ruche {
    
    private String id;
    
    @JsonProperty("nom")
    private String nom;
    
    @JsonProperty("apiculteur_id")
    private String apiculteurId;
    
    @JsonProperty("rucher_id")
    private String rucherId;
    
    @JsonProperty("rucher_nom")
    private String rucherNom;
    
    // Données des capteurs IoT
    @JsonProperty("temperature")
    private Double temperature;
    
    @JsonProperty("humidite")
    private Double humidite;
    
    @JsonProperty("couvercle_ouvert")
    private Boolean couvercleOuvert = false;
    
    @JsonProperty("niveau_batterie")
    private Integer niveauBatterie;
    
    @JsonProperty("derniere_mise_a_jour")
    private LocalDateTime derniereMiseAJour;
    
    // Informations de la ruche
    @JsonProperty("description")
    private String description;
    
    @JsonProperty("position_lat")
    private Double positionLat;
    
    @JsonProperty("position_lng")
    private Double positionLng;
    
    @JsonProperty("type_ruche")
    private String typeRuche;
    
    @JsonProperty("date_installation")
    private LocalDateTime dateInstallation;
    
    @JsonProperty("actif")
    private boolean actif = true;
    
    @JsonProperty("created_at")
    private LocalDateTime createdAt;
    
    @JsonProperty("poids")
    private Double poids;
    
    @JsonProperty("derniere_sync")
    private LocalDateTime derniereSync;
    
    // Seuils d'alerte
    @JsonProperty("seuil_temp_min")
    private Double seuilTempMin = 15.0;
    
    @JsonProperty("seuil_temp_max")
    private Double seuilTempMax = 35.0;
    
    @JsonProperty("seuil_humidite_min")
    private Double seuilHumiditeMin = 40.0;
    
    @JsonProperty("seuil_humidite_max")
    private Double seuilHumiditeMax = 70.0;

    private DonneesCapteur dernieresDonnees;

    // Constructors
    public Ruche() {}

    // Getters and Setters
    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getNom() {
        return nom;
    }

    public void setNom(String nom) {
        this.nom = nom;
    }

    public String getApiculteurId() {
        return apiculteurId;
    }

    public void setApiculteurId(String apiculteurId) {
        this.apiculteurId = apiculteurId;
    }

    public String getRucherId() {
        return rucherId;
    }

    public void setRucherId(String rucherId) {
        this.rucherId = rucherId;
    }

    public String getRucherNom() {
        return rucherNom;
    }

    public void setRucherNom(String rucherNom) {
        this.rucherNom = rucherNom;
    }

    public Double getTemperature() {
        return temperature;
    }

    public void setTemperature(Double temperature) {
        this.temperature = temperature;
    }

    public Double getHumidite() {
        return humidite;
    }

    public void setHumidite(Double humidite) {
        this.humidite = humidite;
    }

    public Boolean getCouvercleOuvert() {
        return couvercleOuvert;
    }

    public void setCouvercleOuvert(Boolean couvercleOuvert) {
        this.couvercleOuvert = couvercleOuvert;
    }

    public Integer getNiveauBatterie() {
        return niveauBatterie;
    }

    public void setNiveauBatterie(Integer niveauBatterie) {
        this.niveauBatterie = niveauBatterie;
    }

    public LocalDateTime getDerniereMiseAJour() {
        return derniereMiseAJour;
    }

    public void setDerniereMiseAJour(LocalDateTime derniereMiseAJour) {
        this.derniereMiseAJour = derniereMiseAJour;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public Double getPositionLat() {
        return positionLat;
    }

    public void setPositionLat(Double positionLat) {
        this.positionLat = positionLat;
    }

    public Double getPositionLng() {
        return positionLng;
    }

    public void setPositionLng(Double positionLng) {
        this.positionLng = positionLng;
    }

    public String getTypeRuche() {
        return typeRuche;
    }

    public void setTypeRuche(String typeRuche) {
        this.typeRuche = typeRuche;
    }

    public LocalDateTime getDateInstallation() {
        return dateInstallation;
    }

    public void setDateInstallation(LocalDateTime dateInstallation) {
        this.dateInstallation = dateInstallation;
    }

    public boolean isActif() {
        return actif;
    }

    public void setActif(boolean actif) {
        this.actif = actif;
    }

    public Double getSeuilTempMin() {
        return seuilTempMin;
    }

    public void setSeuilTempMin(Double seuilTempMin) {
        this.seuilTempMin = seuilTempMin;
    }

    public Double getSeuilTempMax() {
        return seuilTempMax;
    }

    public void setSeuilTempMax(Double seuilTempMax) {
        this.seuilTempMax = seuilTempMax;
    }

    public Double getSeuilHumiditeMin() {
        return seuilHumiditeMin;
    }

    public void setSeuilHumiditeMin(Double seuilHumiditeMin) {
        this.seuilHumiditeMin = seuilHumiditeMin;
    }

    public Double getSeuilHumiditeMax() {
        return seuilHumiditeMax;
    }

    public void setSeuilHumiditeMax(Double seuilHumiditeMax) {
        this.seuilHumiditeMax = seuilHumiditeMax;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public Double getPoids() {
        return poids;
    }

    public void setPoids(Double poids) {
        this.poids = poids;
    }

    public LocalDateTime getDerniereSync() {
        return derniereSync;
    }

    public void setDerniereSync(LocalDateTime derniereSync) {
        this.derniereSync = derniereSync;
    }

    public DonneesCapteur getDernieresDonnees() {
        return dernieresDonnees;
    }

    public void setDernieresDonnees(DonneesCapteur dernieresDonnees) {
        this.dernieresDonnees = dernieresDonnees;
    }
} 