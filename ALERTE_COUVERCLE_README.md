# 🚨 Système d'Alerte Couvercle - BeeTrack

## 📋 Vue d'ensemble

Ce système implémente une surveillance en temps réel de l'état du couvercle des ruches avec alertes automatiques et gestion des préférences d'ignore.

## 🏗️ Architecture

### Services
- **`AlerteCouvercleService`** : Service singleton pour gérer la surveillance et les règles d'ignore
- **`ApiRucheService`** : Service pour les appels API vers le backend Spring Boot

### Hooks React
- **`useAlertesCouvercle`** : Hook principal pour gérer les alertes dans les composants
- **`useNotifications`** : Hook pour gérer les notifications toast

### Composants
- **`AlerteCouvercleModal`** : Modal d'alerte avec options d'ignore
- **`NotificationToast`** : Composant de notification toast
- **`SurveillanceCouvercle`** : Interface de contrôle de surveillance pour une ruche
- **`TestAlerteCouvercle`** : Composant de test et démonstration

## 🔧 Fonctionnalités

### 1. Surveillance en Temps Réel
- Vérification automatique toutes les 30 secondes
- Appel à l'API `/mesures/last?idRuche={id}`
- Détection de `couvercleOuvert === true`

### 2. Système d'Alertes
- Modal popup visuellement marquante
- Informations détaillées de la mesure
- Actions recommandées pour l'utilisateur

### 3. Gestion des Préférences d'Ignore
- **Ignore temporaire** : 30min, 1h, 2h, 4h, 8h, 24h
- **Ignore session** : Jusqu'à fermeture de l'application
- Stockage dans `localStorage` du navigateur
- Nettoyage automatique des règles expirées

### 4. Interface Utilisateur
- Onglet "Surveillance" dans les détails de ruche
- Contrôles start/stop de surveillance
- Indicateurs visuels d'état
- Notifications toast pour les actions

## 🚀 Utilisation

### Démarrer la Surveillance
```typescript
const alertes = useAlertesCouvercle({
  apiculteurId: 'user-id',
  onNotification: addNotification
});

// Démarrer surveillance d'une ruche
alertes.demarrerSurveillance('ruche-id', 'Nom de la ruche');
```

### Gérer les Alertes
```typescript
// Ignorer temporairement (1 heure)
alertes.ignorerAlerte(1);

// Ignorer pour la session
alertes.ignorerPourSession();

// Réactiver les alertes
alertes.reactiverAlertes('ruche-id');
```

### Vérifier le Statut
```typescript
const statut = alertes.obtenirStatutIgnore('ruche-id');
// { ignore: boolean, type?: 'session' | 'temporaire', finIgnore?: Date }
```

## 📱 Test et Démonstration

Accédez à l'onglet **"Test Alerte"** dans l'application pour :
1. Démarrer une surveillance de test
2. Simuler une alerte de couvercle ouvert
3. Tester les options d'ignore
4. Observer les notifications en temps réel

## 🔧 Configuration

### Paramètres Modifiables
```typescript
// Dans AlerteCouvercleService
private readonly INTERVAL_MS = 30000; // Fréquence de vérification
private readonly STORAGE_KEY = 'beetrackAlertesIgnore'; // Clé localStorage
```

### API Endpoint
```typescript
// Dans ApiRucheService
const API_BASE_URL = 'http://localhost:8080';
const endpoint = `/api/mobile/ruches/${rucheId}/derniere-mesure`;
```

## 🛡️ Gestion d'Erreurs

- **Erreurs réseau** : Gestion gracieuse avec callback d'erreur
- **Données manquantes** : Vérification de nullité
- **localStorage** : Try/catch pour les erreurs de stockage
- **Nettoyage** : Arrêt automatique des surveillances au démontage

## 📊 Stockage Local

Les règles d'ignore sont stockées dans `localStorage` :
```json
{
  "beetrackAlertesIgnore": [
    {
      "rucheId": "ruche-123",
      "timestamp": 1703123456789,
      "dureeMs": 3600000,
      "type": "temporaire"
    }
  ]
}
```

## 🔄 Cycle de Vie

1. **Initialisation** : Service singleton créé
2. **Surveillance** : Interval démarré pour une ruche
3. **Vérification** : Appel API toutes les 30s
4. **Détection** : Si `couvercleOuvert === true`
5. **Filtrage** : Vérification des règles d'ignore
6. **Alerte** : Affichage modal si non ignoré
7. **Action** : Utilisateur choisit ignore ou ferme
8. **Nettoyage** : Arrêt surveillance au démontage

## 🎯 Bonnes Pratiques Implémentées

- ✅ **Singleton Pattern** pour le service
- ✅ **React Hooks** pour la gestion d'état
- ✅ **TypeScript** pour la sécurité des types
- ✅ **Error Handling** robuste
- ✅ **Cleanup** automatique des ressources
- ✅ **localStorage** pour la persistance
- ✅ **UI/UX** intuitive et accessible
- ✅ **Composants réutilisables**
- ✅ **Tests** et démonstration intégrés

## 🔮 Extensions Possibles

- WebSocket pour temps réel instantané
- Notifications push navigateur
- Historique des alertes
- Règles d'ignore avancées (horaires, jours)
- Intégration avec calendrier apicole
- Alertes par email/SMS
- Dashboard de surveillance globale 