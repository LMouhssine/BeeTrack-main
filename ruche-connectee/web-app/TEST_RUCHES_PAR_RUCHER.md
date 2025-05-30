# Test - Récupération des Ruches par Rucher avec Tri

## 🎯 Fonctionnalité testée

**Endpoint :** `GET /api/mobile/ruches/rucher/{rucherId}`

**Objectif :** Récupérer les ruches associées à un rucher spécifique, triées par nom croissant.

## 🔧 Configuration du test

### 1. Prérequis
- Spring Boot en cours d'exécution sur `localhost:8080`
- Authentification Firebase configurée
- Base de données Firestore avec des ruches de test

### 2. Données de test suggérées

Créer plusieurs ruches dans le même rucher avec des noms dans le désordre :

```json
{
  "nom": "Ruche Zulu",
  "position": "Z1",
  "idRucher": "rucher_test_123",
  "actif": true
}

{
  "nom": "Ruche Alpha",
  "position": "A1", 
  "idRucher": "rucher_test_123",
  "actif": true
}

{
  "nom": "Ruche Beta",
  "position": "B1",
  "idRucher": "rucher_test_123",
  "actif": true
}
```

## 🧪 Tests manuels

### Test 1 : Avec curl

```bash
curl -X GET "http://localhost:8080/api/mobile/ruches/rucher/rucher_test_123" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_FIREBASE_TOKEN" \
  -H "X-Apiculteur-ID: YOUR_USER_ID"
```

### Test 2 : Avec un outil REST (Postman, Insomnia)

**URL :** `http://localhost:8080/api/mobile/ruches/rucher/rucher_test_123`

**Headers :**
- `Content-Type: application/json`
- `Authorization: Bearer YOUR_FIREBASE_TOKEN`
- `X-Apiculteur-ID: YOUR_USER_ID`

**Méthode :** GET

## ✅ Résultat attendu

Les ruches doivent être retournées dans l'ordre alphabétique croissant par nom :

```json
[
  {
    "id": "ruche_alpha_id",
    "nom": "Ruche Alpha",
    "position": "A1",
    "idRucher": "rucher_test_123",
    "actif": true,
    ...
  },
  {
    "id": "ruche_beta_id", 
    "nom": "Ruche Beta",
    "position": "B1",
    "idRucher": "rucher_test_123",
    "actif": true,
    ...
  },
  {
    "id": "ruche_zulu_id",
    "nom": "Ruche Zulu", 
    "position": "Z1",
    "idRucher": "rucher_test_123",
    "actif": true,
    ...
  }
]
```

## 🔍 Points de validation

1. **Tri correct :** Les ruches sont bien triées par nom croissant
2. **Filtrage rucher :** Seules les ruches du rucher demandé sont retournées
3. **Sécurité :** Seules les ruches de l'utilisateur connecté sont visibles
4. **Gestion des noms null :** Les ruches sans nom sont gérées correctement
5. **Insensibilité à la casse :** Le tri ignore la casse des caractères

## 🚨 Cas d'erreur à tester

### Rucher inexistant
```bash
curl -X GET "http://localhost:8080/api/mobile/ruches/rucher/rucher_inexistant"
```
**Attendu :** Retour d'une liste vide `[]`

### Accès non autorisé
```bash
curl -X GET "http://localhost:8080/api/mobile/ruches/rucher/rucher_autre_utilisateur"
```
**Attendu :** Retour d'une liste vide `[]` (filtrage par apiculteurId)

### Token invalide
```bash
curl -X GET "http://localhost:8080/api/mobile/ruches/rucher/rucher_test_123" \
  -H "Authorization: Bearer token_invalide"
```
**Attendu :** Erreur 401 ou 403

## 📝 Journal des tests

Date : _________
Testeur : _________

- [ ] Test tri alphabétique : OK / KO
- [ ] Test filtrage rucher : OK / KO  
- [ ] Test sécurité utilisateur : OK / KO
- [ ] Test cas d'erreur : OK / KO
- [ ] Performance acceptable : OK / KO

**Commentaires :**
_________________________________
_________________________________
_________________________________ 