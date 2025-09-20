# Système d'Alertes en Temps Réel - BeeTrack

## Vue d'ensemble

Le système d'alertes en temps réel de BeeTrack permet de surveiller automatiquement les ruches connectées et d'envoyer des notifications par email lorsque des événements critiques sont détectés, notamment l'ouverture du couvercle d'une ruche.

## Architecture

### Composants principaux

1. **FirebaseRealtimeListenerService** : Service de surveillance en temps réel
2. **NotificationService** : Service d'envoi d'emails et gestion des inhibitions
3. **AlerteController** : API REST pour la gestion des alertes
4. **InhibitionController** : API REST pour la gestion des inhibitions
5. **Interface web** : Page de gestion des alertes (`/alertes`)

### Flux de données

```
Firebase Realtime Database
         ↓
FirebaseRealtimeListenerService
         ↓
NotificationService (si alerte détectée)
         ↓
Email SMTP (si pas inhibé)
```

## Configuration

### 1. Configuration Email

Dans `application.properties` :

```properties
# Configuration Email (pour les notifications d'alerte)
spring.mail.host=smtp.gmail.com
spring.mail.port=587
spring.mail.username=beetrack.alerts@gmail.com
spring.mail.password=your-app-password
spring.mail.properties.mail.smtp.auth=true
spring.mail.properties.mail.smtp.starttls.enable=true
spring.mail.properties.mail.smtp.starttls.required=true
```

### 2. Configuration Firebase

```properties
firebase.project-id=rucheconnecteeesp32
firebase.database-url=https://rucheconnecteeesp32-default-rtdb.europe-west1.firebasedatabase.app
firebase.credentials-path=firebase-service-account.json
```

## Fonctionnalités

### 1. Surveillance en Temps Réel

Le `FirebaseRealtimeListenerService` surveille automatiquement :

- **Mesures générales** : Toutes les nouvelles mesures dans Firebase
- **Couvercle ouvert** : Détection automatique de l'ouverture du couvercle
- **Seuils de température** : Alertes si température < 15°C ou > 35°C
- **Seuils d'humidité** : Alertes si humidité < 40% ou > 70%

### 2. Système d'Inhibition

Le `NotificationService` gère les inhibitions temporaires :

- **Activation** : Suppression temporaire des alertes pour une ruche
- **Durée configurable** : De 1 à 24 heures
- **Expiration automatique** : Nettoyage automatique des inhibitions expirées
- **Statut consultable** : API pour vérifier l'état des inhibitions

### 3. Notifications Email

Format d'email automatique :

```
Sujet: 🚨 ALERTE - Couvercle ouvert détecté

Bonjour [Prénom],

🚨 Une alerte a été déclenchée pour votre ruche.

📋 Détails de l'alerte:
• Ruche: [Nom de la ruche]
• Type: Couvercle ouvert
• Heure: [Timestamp]
• Température: [Valeur]°C
• Humidité: [Valeur]%

🔧 Actions recommandées:
1. Vérifier l'état de la ruche
2. S'assurer qu'aucune intervention n'est en cours
3. Contacter l'équipe si nécessaire

📱 Vous pouvez également consulter l'application mobile pour plus de détails.

Cordialement,
L'équipe BeeTrack
```

## API Endpoints

### AlerteController (`/api/alertes`)

| Méthode | Endpoint | Description |
|---------|----------|-------------|
| GET | `/statut` | Statut de la surveillance |
| POST | `/test` | Test d'envoi d'alerte |
| POST | `/surveillance/{rucheId}/demarrer` | Démarrer surveillance spécifique |
| POST | `/surveillance/{rucheId}/arreter` | Arrêter surveillance spécifique |
| GET | `/inhibition/{rucheId}` | Statut d'inhibition d'une ruche |
| GET | `/inhibition/actives` | Toutes les inhibitions actives |

### InhibitionController (`/api/inhibitions`)

| Méthode | Endpoint | Description |
|---------|----------|-------------|
| POST | `/{rucheId}/activer` | Activer inhibition temporaire |
| POST | `/{rucheId}/desactiver` | Désactiver inhibition |
| GET | `/{rucheId}/statut` | Statut d'inhibition |
| GET | `/actives` | Toutes les inhibitions actives |
| POST | `/nettoyer` | Nettoyer les inhibitions expirées |

## Interface Web

### Page de Gestion des Alertes (`/alertes`)

Fonctionnalités disponibles :

1. **Statut de Surveillance**
   - État actif/inactif de la surveillance
   - Nombre de ruches surveillées
   - Liste des ruches surveillées

2. **Test d'Alerte**
   - Formulaire pour tester l'envoi d'alerte
   - Simulation d'ouverture de couvercle

3. **Gestion des Inhibitions**
   - Affichage des inhibitions actives
   - Durée restante pour chaque inhibition

4. **Logs d'Alertes**
   - Historique des actions effectuées
   - Messages de succès/erreur

## Tests

### Script de Test Automatisé

```bash
# Exécuter le script de test
scripts/test-alertes-system.bat
```

### Tests Manuels

1. **Test de l'API** :
```bash
curl -X GET http://localhost:8080/api/alertes/statut
```

2. **Test d'alerte** (nécessite authentification) :
```bash
curl -X POST http://localhost:8080/api/alertes/test \
  -H "Content-Type: application/json" \
  -d '{"rucheId": "ruche_001"}'
```

3. **Test d'inhibition** (nécessite authentification) :
```bash
curl -X POST http://localhost:8080/api/inhibitions/ruche_001/activer \
  -H "Content-Type: application/json" \
  -d '{"dureeHeures": 2}'
```

## Structure des Données Firebase

### Mesures (`/mesures`)

```json
{
  "mesure_001": {
    "rucheId": "ruche_001",
    "temperature": 25.5,
    "humidite": 65.0,
    "couvercleOuvert": true,
    "timestamp": "2025-01-24T18:31:39"
  }
}
```

### Ruches (`/ruches`)

```json
{
  "ruche_001": {
    "id": "ruche_001",
    "nom": "Ruche Alpha",
    "apiculteurId": "apiculteur_001",
    "actif": true
  }
}
```

### Apiculteurs (`/apiculteurs`)

```json
{
  "apiculteur_001": {
    "id": "apiculteur_001",
    "email": "jean.dupont@email.com",
    "nom": "Dupont",
    "prenom": "Jean"
  }
}
```

## Sécurité

### Authentification

- Toutes les API d'alertes nécessitent une authentification
- Utilisation de Spring Security avec Firebase Auth
- Rôles : `ROLE_USER` (apiculteurs), `ROLE_ADMIN` (gestionnaires)

### Validation

- Validation des paramètres d'entrée
- Vérification de l'existence des ruches et apiculteurs
- Gestion des erreurs avec messages appropriés

## Monitoring et Logs

### Logs de Surveillance

```
🚀 Initialisation du service de surveillance Firebase Realtime Database
✅ Surveillance générale des mesures démarrée
🚨 Couvercle ouvert détecté pour la ruche: ruche_001
✅ Email d'alerte envoyé à: jean.dupont@email.com
🔇 Alerte inhibée pour la ruche: ruche_001
```

### Métriques Disponibles

- Nombre de ruches surveillées
- Nombre d'alertes envoyées
- Nombre d'inhibitions actives
- Temps de réponse des API

## Dépannage

### Problèmes Courants

1. **Emails non envoyés**
   - Vérifier la configuration SMTP
   - Vérifier les identifiants Gmail
   - Vérifier les logs d'erreur

2. **Surveillance inactive**
   - Vérifier la connexion Firebase
   - Vérifier les permissions Firebase
   - Redémarrer l'application

3. **Inhibitions non respectées**
   - Vérifier l'heure système
   - Vérifier les logs d'inhibition
   - Forcer le nettoyage des inhibitions

### Commandes de Diagnostic

```bash
# Vérifier le statut de surveillance
curl http://localhost:8080/api/alertes/statut

# Vérifier les inhibitions actives
curl http://localhost:8080/api/alertes/inhibition/actives

# Nettoyer les inhibitions expirées
curl -X POST http://localhost:8080/api/inhibitions/nettoyer
```

## Évolutions Futures

### Fonctionnalités Prévues

1. **Notifications Push** : Intégration avec Firebase Cloud Messaging
2. **Alertes SMS** : Intégration avec un service SMS
3. **Seuils personnalisés** : Configuration par ruche
4. **Historique des alertes** : Stockage en base de données
5. **Escalade automatique** : Notification des administrateurs

### Améliorations Techniques

1. **Performance** : Optimisation des listeners Firebase
2. **Fiabilité** : Système de retry pour les emails
3. **Monitoring** : Métriques avancées avec Prometheus
4. **Tests** : Tests unitaires et d'intégration complets 