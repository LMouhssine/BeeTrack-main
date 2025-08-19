package com.rucheconnectee.model;

/**
 * Modèle pour la collection "ApiculteursNew".
 * Remarque: le mot de passe n'est pas persistant en base; il est utilisé uniquement pour Firebase Auth.
 */
public class ApiculteursNew {

    private String id;          // UID Firebase Auth (lors de la création)
    private String email;
    private String prenom;
    private String nom;
    private String role;        // "admin" ou "apiculteur"
    private Long createdAt;     // epoch millis

    // Champ non persistant, utilisé pour création/mise à jour Auth
    private String password;

    public ApiculteursNew() {}

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getPrenom() { return prenom; }
    public void setPrenom(String prenom) { this.prenom = prenom; }

    public String getNom() { return nom; }
    public void setNom(String nom) { this.nom = nom; }

    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }

    public Long getCreatedAt() { return createdAt; }
    public void setCreatedAt(Long createdAt) { this.createdAt = createdAt; }

    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }
}







