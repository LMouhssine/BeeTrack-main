package com.rucheconnectee.model;

import com.fasterxml.jackson.annotation.JsonProperty;
import java.time.LocalDateTime;

/**
 * DTO de réponse pour les ruches avec informations du rucher.
 * Compatible avec l'interface mobile Flutter.
 */
public class RucheResponse {
    
    @JsonProperty("id")
    private String id;
    
    @JsonProperty("nom")
    private String nom;
    
    @JsonProperty("position")
    private String position;
    
    @JsonProperty("idRucher")
    private String idRucher;
    
    @JsonProperty("rucherNom")
    private String rucherNom;
    
    @JsonProperty("rucherAdresse")
    private String rucherAdresse;
    
    @JsonProperty("enService")
    private boolean enService;
    
    @JsonProperty("dateInstallation")
    private LocalDateTime dateInstallation;
    
    @JsonProperty("dateCreation")
    private LocalDateTime dateCreation;
    
    @JsonProperty("dateMiseAJour")
    private LocalDateTime dateMiseAJour;
    
    @JsonProperty("idApiculteur")
    private String idApiculteur;
    
    @JsonProperty("actif")
    private boolean actif;
    
    @JsonProperty("typeRuche")
    private String typeRuche;
    
    @JsonProperty("description")
    private String description;
    
    // Données capteurs (optionnelles)
    @JsonProperty("temperature")
    private Double temperature;
    
    @JsonProperty("humidite")
    private Double humidite;
    
    @JsonProperty("couvercleOuvert")
    private Boolean couvercleOuvert;
    
    @JsonProperty("niveauBatterie")
    private Integer niveauBatterie;
    
    // Constructeurs
    public RucheResponse() {}
    
    /**
     * Convertit un objet Ruche en RucheResponse
     */
    public static RucheResponse fromRuche(Ruche ruche) {
        RucheResponse response = new RucheResponse();
        response.setId(ruche.getId());
        response.setNom(ruche.getNom());
        response.setIdRucher(ruche.getRucherId());
        response.setRucherNom(ruche.getRucherNom());
        response.setIdApiculteur(ruche.getApiculteurId());
        response.setTypeRuche(ruche.getTypeRuche());
        response.setDescription(ruche.getDescription());
        response.setDateInstallation(ruche.getDateInstallation());
        response.setDateCreation(ruche.getDateInstallation()); // Utiliser dateInstallation comme dateCreation
        response.setDateMiseAJour(ruche.getDerniereMiseAJour());
        response.setActif(ruche.isActif());
        response.setTemperature(ruche.getTemperature());
        response.setHumidite(ruche.getHumidite());
        response.setCouvercleOuvert(ruche.getCouvercleOuvert());
        response.setNiveauBatterie(ruche.getNiveauBatterie());
        
        // Le statut enService est déduit de l'activité et de l'absence d'alertes critiques
        response.setEnService(ruche.isActif());
        
        return response;
    }
    
    /**
     * Définit la position dans le rucher (mapper depuis description ou autre champ)
     */
    public void setPositionFromDescription() {
        if (this.description != null && this.description.contains("Position:")) {
            String[] parts = this.description.split("Position:");
            if (parts.length > 1) {
                this.position = parts[1].trim().split(" ")[0];
            }
        }
        if (this.position == null) {
            this.position = "Non définie";
        }
    }
    
    // Getters et Setters
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
    
    public String getPosition() {
        return position;
    }
    
    public void setPosition(String position) {
        this.position = position;
    }
    
    public String getIdRucher() {
        return idRucher;
    }
    
    public void setIdRucher(String idRucher) {
        this.idRucher = idRucher;
    }
    
    public String getRucherNom() {
        return rucherNom;
    }
    
    public void setRucherNom(String rucherNom) {
        this.rucherNom = rucherNom;
    }
    
    public String getRucherAdresse() {
        return rucherAdresse;
    }
    
    public void setRucherAdresse(String rucherAdresse) {
        this.rucherAdresse = rucherAdresse;
    }
    
    public boolean isEnService() {
        return enService;
    }
    
    public void setEnService(boolean enService) {
        this.enService = enService;
    }
    
    public LocalDateTime getDateInstallation() {
        return dateInstallation;
    }
    
    public void setDateInstallation(LocalDateTime dateInstallation) {
        this.dateInstallation = dateInstallation;
    }
    
    public LocalDateTime getDateCreation() {
        return dateCreation;
    }
    
    public void setDateCreation(LocalDateTime dateCreation) {
        this.dateCreation = dateCreation;
    }
    
    public LocalDateTime getDateMiseAJour() {
        return dateMiseAJour;
    }
    
    public void setDateMiseAJour(LocalDateTime dateMiseAJour) {
        this.dateMiseAJour = dateMiseAJour;
    }
    
    public String getIdApiculteur() {
        return idApiculteur;
    }
    
    public void setIdApiculteur(String idApiculteur) {
        this.idApiculteur = idApiculteur;
    }
    
    public boolean isActif() {
        return actif;
    }
    
    public void setActif(boolean actif) {
        this.actif = actif;
    }
    
    public String getTypeRuche() {
        return typeRuche;
    }
    
    public void setTypeRuche(String typeRuche) {
        this.typeRuche = typeRuche;
    }
    
    public String getDescription() {
        return description;
    }
    
    public void setDescription(String description) {
        this.description = description;
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
} 