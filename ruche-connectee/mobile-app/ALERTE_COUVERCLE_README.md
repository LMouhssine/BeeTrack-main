# Système d'Alerte Couvercle - Flutter Mobile

## Vue d'ensemble

Le système d'alerte couvercle pour l'application mobile Flutter surveille en temps réel l'état des ruches et déclenche des alertes lorsque le couvercle d'une ruche est ouvert de manière non autorisée.

## Architecture

### Services

#### AlerteCouvercleService
Service singleton qui gère la surveillance en temps réel :
- **Surveillance** : Timer périodique (30 secondes) par ruche
- **API** : Appel à `/api/mobile/ruches/{id}/mesures/last`
- **Stockage** : SharedPreferences pour les règles d'ignore
- **Callbacks** : Notifications d'alerte et d'erreur

#### ApiRucheService
Service API étendu avec :
- `obtenirDerniereMesure(String rucheId)` : Récupère la dernière mesure d'une ruche
- Gestion d'erreur avec fallback Firestore

### État (BLoC Pattern)

#### AlerteCouvercleBloc
Gestion de l'état avec flutter_bloc :
- **Events** : Démarrer/arrêter surveillance, ignorer alertes, etc.
- **State** : Ruches surveillées, alerte active, statuts ignore
- **Logic** : Coordination entre service et UI

#### Événements principaux
- `DemarrerSurveillanceEvent` : Démarre la surveillance d'une ruche
- `ArreterSurveillanceEvent` : Arrête la surveillance
- `AlerteDeclenCheeEvent` : Alerte détectée
- `IgnorerAlerteEvent` : Ignore temporairement
- `IgnorerPourSessionEvent` : Ignore pour la session

### Interface Utilisateur

#### AlerteCouvercleModal
Modal d'alerte avec animation :
- **Design** : Interface moderne avec gradient rouge/orange
- **Information** : Détails de la ruche et mesures
- **Actions** : Options d'ignore avec durées configurables
- **Accessibilité** : Boutons clairs et navigation intuitive

#### SurveillanceCouvercleWidget
Widget de contrôle de surveillance :
- **Status** : Indicateur visuel de l'état de surveillance
- **Controls** : Boutons démarrer/arrêter
- **Info** : Statistiques et configuration

#### TestAlerteCouvercleScreen
Écran de test et démonstration :
- **Simulation** : Génération d'alertes factices
- **Debug** : Informations d'état détaillées
- **Instructions** : Guide d'utilisation

## Fonctionnalités

### Surveillance Temps Réel
```dart
// Démarrer la surveillance
alerteService.demarrerSurveillance(
  rucheId,
  apiculteurId,
  rucheNom: 'Ma Ruche',
  onAlerte: (rucheId, mesure) {
    // Déclencher l'alerte dans l'UI
  },
  onErreur: (rucheId, erreur) {
    // Gérer l'erreur
  },
);
```

### Système d'Ignore
```dart
// Ignore temporaire
await alerteService.ignorerAlerte(rucheId, 2.0); // 2 heures

// Ignore pour session
await alerteService.ignorerPourSession(rucheId);

// Réactiver
await alerteService.reactiverAlertes(rucheId);
```

### Persistance des Règles
```dart
// Les règles sont automatiquement sauvegardées
final statut = await alerteService.obtenirStatutIgnore(rucheId);
if (statut['ignore'] == true) {
  // Alerte ignorée
}
```

## Configuration

### Durées d'Ignore Disponibles
- 30 minutes
- 1 heure  
- 2 heures
- 4 heures
- 8 heures
- 24 heures
- Session (jusqu'à fermeture app)

### Paramètres
```dart
class AlerteCouvercleService {
  static const int _intervalMs = 30000; // 30 secondes
  static const String _storageKey = 'beetrackAlertesIgnore';
}
```

## API Endpoints

### Dernière Mesure
```
GET /api/mobile/ruches/{rucheId}/mesures/last
```

**Réponse** :
```json
{
  "id": "mesure-id",
  "rucheId": "ruche-id",
  "timestamp": "2024-01-15T10:30:00Z",
  "temperature": 25.5,
  "humidity": 65.2,
  "couvercleOuvert": true,
  "batterie": 85,
  "signalQualite": 92,
  "erreur": null
}
```

## Utilisation

### Intégration dans un écran de ruche
```dart
class RucheDetailsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AlerteCouvercleBloc(
        GetIt.instance<AlerteCouvercleService>(),
      ),
      child: Scaffold(
        body: Column(
          children: [
            // Autres widgets de la ruche...
            SurveillanceCouvercleWidget(
              rucheId: widget.rucheId,
              rucheNom: widget.rucheNom,
              apiculteurId: widget.apiculteurId,
            ),
          ],
        ),
      ),
    );
  }
}
```

### Modal d'alerte globale
```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AlerteCouvercleBloc, AlerteCouvercleState>(
      listener: (context, state) {
        if (state.alerteActive != null) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlerteCouvercleModal(
              rucheId: state.alerteActive!.rucheId,
              rucheNom: state.alerteActive!.rucheNom,
              mesure: state.alerteActive!.mesure,
              onIgnorerTemporairement: (duree) {
                context.read<AlerteCouvercleBloc>().add(
                  IgnorerAlerteEvent(
                    rucheId: state.alerteActive!.rucheId,
                    dureeHeures: duree,
                  ),
                );
                Navigator.of(context).pop();
              },
              onIgnorerSession: () {
                context.read<AlerteCouvercleBloc>().add(
                  IgnorerPourSessionEvent(state.alerteActive!.rucheId),
                );
                Navigator.of(context).pop();
              },
              onFermer: () {
                context.read<AlerteCouvercleBloc>().add(FermerAlerteEvent());
                Navigator.of(context).pop();
              },
            ),
          );
        }
      },
      builder: (context, state) {
        return MaterialApp(
          // Configuration de l'app...
        );
      },
    );
  }
}
```

## Tests et Debug

### Écran de Test
L'écran `TestAlerteCouvercleScreen` permet de :
1. Démarrer/arrêter la surveillance
2. Simuler des alertes
3. Tester les options d'ignore
4. Voir les informations de debug

### Navigation vers le test
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const TestAlerteCouvercleScreen(),
  ),
);
```

## Gestion des Erreurs

### Erreurs API
- Timeout de connexion
- Erreur serveur (500)
- Ruche non trouvée (404)
- Fallback vers Firestore si disponible

### Erreurs de Stockage
- Données corrompues : nettoyage automatique
- Échec de sauvegarde : log et continuation
- Migration de format : gestion automatique

## Performance

### Optimisations
- Endpoint `/mesures/last` au lieu de `/mesures-7-jours`
- Nettoyage automatique des règles expirées
- Timers indépendants par ruche
- Sérialisation JSON optimisée

### Monitoring
```dart
final stats = await alerteService.obtenirStatistiques();
print('Ruches surveillées: ${stats['ruchesEnSurveillance']}');
print('Règles actives: ${stats['reglesTemporaireActives']}');
```

## Lifecycle

### Initialisation
```dart
void main() {
  // Configuration des services
  final alerteService = AlerteCouvercleService.instance;
  alerteService.init(GetIt.instance<ApiRucheService>());
  
  runApp(MyApp());
}
```

### Nettoyage
```dart
class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    // Nettoyer les règles de session
    AlerteCouvercleService.instance.nettoyerReglesSession();
    AlerteCouvercleService.instance.arreterToutesSurveillances();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // App en arrière-plan : conserver surveillance
    } else if (state == AppLifecycleState.detached) {
      // App fermée : nettoyer
      AlerteCouvercleService.instance.nettoyerReglesSession();
    }
  }
}
```

## Extensibilité

### Ajout de nouveaux types d'alertes
1. Étendre `DonneesCapteur` avec nouveaux champs
2. Ajouter logique de détection dans `surveillerRuche()`
3. Créer nouvelles modales d'alerte
4. Ajouter nouveaux événements BLoC

### Notifications Push
Integration future avec Firebase Cloud Messaging :
```dart
// Dans AlerteCouvercleService
void _envoyerNotificationPush(String rucheId, DonneesCapteur mesure) {
  // Intégration FCM
}
```

### Analytics
```dart
// Tracking des événements d'alerte
void _trackAlerteEvent(String rucheId, String action) {
  // Firebase Analytics
}
``` 