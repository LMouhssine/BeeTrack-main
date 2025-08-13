package com.rucheconnectee.model;

/**
 * Modèle simple pour la collection "RuchesNew".
 * Champs requis: nom (nom de la ruche), ruchesid (identifiant), description.
 */
public class RuchesNew {

    private String id;          // ID auto-généré dans Firebase
    private String nom;         // Nom de la ruche
    private String ruchesid;    // Identifiant métier saisi par l'utilisateur
    private String description; // Description libre
    private String rucherId;    // Référence au RuchersNew sélectionné

    public RuchesNew() {
    }

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

    public String getRuchesid() {
        return ruchesid;
    }

    public void setRuchesid(String ruchesid) {
        this.ruchesid = ruchesid;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getRucherId() {
        return rucherId;
    }

    public void setRucherId(String rucherId) {
        this.rucherId = rucherId;
    }
}


