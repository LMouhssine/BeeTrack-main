# Service de Gestion des Ruches - Documentation

## Vue d'ensemble

Le `RucheService` est un service Flutter qui gère toutes les opérations CRUD (Create, Read, Update, Delete) pour les ruches dans l'application BeeTrack. Il utilise Firebase Firestore comme backend et assure la validation de sécurité et la cohérence des données.

## Fonctionnalités principales

### ✅ Ajout de ruches
- Validation de l'existence du rucher
- Vérification des permissions utilisateur
- Mise à jour automatique du compteur de ruches dans le rucher
- Utilisation de transactions pour la cohérence des données

### ✅ Récupération de ruches
- Par rucher spécifique
- Toutes les ruches de l'utilisateur
- Par ID de ruche

### ✅ Mise à jour de ruches
- Modification des propriétés de base
- Validation des permissions

### ✅ Suppression logique
- Marquage comme inactif au lieu de suppression physique
- Mise à jour automatique du compteur de ruches

### ✅ Écoute temps réel
- Stream des ruches par rucher
- Stream de toutes les ruches utilisateur

## Structure des données Ruche

```dart
{
  'id': 'string',                    // ID auto-généré par Firestore
  'idRucher': 'string',              // ID du rucher parent (requis)
  'nom': 'string',                   // Nom de la ruche (requis)
  'position': 'string',              // Position dans le rucher (requis)
  'enService': bool,                 // Statut de service (défaut: true)
  'dateInstallation': Timestamp,     // Date d'installation
  'dateCreation': Timestamp,         // Date de création automatique
  'dateModification': Timestamp?,    // Date de dernière modification
  'actif': bool,                     // Statut actif (défaut: true)
  'idApiculteur': 'string',          // ID de l'apiculteur propriétaire
  'dateSuppression': Timestamp?,     // Date de suppression logique
}
```

## Utilisation

### Initialisation

```dart
import 'package:ruche_connectee/services/ruche_service.dart';
import 'package:ruche_connectee/services/firebase_service.dart';

final FirebaseService firebaseService = FirebaseService();
final RucheService rucheService = RucheService(firebaseService);
```

### 1. Ajouter une ruche

```dart
try {
  String rucheId = await rucheService.ajouterRuche(
    idRucher: 'rucher_123',
    nom: 'Ruche A1',
    position: 'A1',
    enService: true,
    dateInstallation: DateTime.now(), // Optionnel
  );
  
  print('Ruche créée avec succès: $rucheId');
} catch (e) {
  print('Erreur lors de l\'ajout: $e');
}
```

**Validations automatiques :**
- ✅ Utilisateur connecté
- ✅ Rucher existe
- ✅ Rucher appartient à l'utilisateur
- ✅ Rucher est actif
- ✅ Mise à jour du compteur de ruches

### 2. Récupérer les ruches d'un rucher

```dart
try {
  List<Map<String, dynamic>> ruches = await rucheService.obtenirRuchesParRucher('rucher_123');
  
  for (var ruche in ruches) {
    print('Ruche: ${ruche['nom']} - Position: ${ruche['position']}');
  }
} catch (e) {
  print('Erreur lors de la récupération: $e');
}
```

### 3. Récupérer toutes les ruches de l'utilisateur

```dart
try {
  List<Map<String, dynamic>> ruchesUtilisateur = await rucheService.obtenirRuchesUtilisateur();
  print('${ruchesUtilisateur.length} ruches trouvées');
} catch (e) {
  print('Erreur: $e');
}
```

### 4. Récupérer une ruche par ID

```dart
try {
  Map<String, dynamic>? ruche = await rucheService.obtenirRucheParId('ruche_456');
  
  if (ruche != null) {
    print('Ruche trouvée: ${ruche['nom']}');
  } else {
    print('Ruche non trouvée');
  }
} catch (e) {
  print('Erreur: $e');
}
```

### 5. Mettre à jour une ruche

```dart
try {
  await rucheService.mettreAJourRuche(
    rucheId: 'ruche_456',
    nom: 'Nouveau nom',
    position: 'B2',
    enService: false,
    dateInstallation: DateTime(2024, 1, 15),
  );
  
  print('Ruche mise à jour avec succès');
} catch (e) {
  print('Erreur lors de la mise à jour: $e');
}
```

### 6. Supprimer une ruche

```dart
try {
  await rucheService.supprimerRuche('ruche_456');
  print('Ruche supprimée avec succès');
} catch (e) {
  print('Erreur lors de la suppression: $e');
}
```

**Note :** La suppression est logique (marquage comme inactif) et met automatiquement à jour le compteur de ruches du rucher.

### 7. Écouter les changements en temps réel

#### Écouter les ruches d'un rucher spécifique

```dart
StreamSubscription? _ruchesSubscription;

void ecouterRuchesRucher(String idRucher) {
  _ruchesSubscription = rucheService.ecouterRuchesParRucher(idRucher)
    .listen(
      (List<Map<String, dynamic>> ruches) {
        setState(() {
          _ruches = ruches;
        });
        print('${ruches.length} ruches mises à jour');
      },
      onError: (error) {
        print('Erreur dans l\'écoute: $error');
      },
    );
}

// N'oubliez pas d'annuler l'abonnement
@override
void dispose() {
  _ruchesSubscription?.cancel();
  super.dispose();
}
```

#### Écouter toutes les ruches de l'utilisateur

```dart
StreamSubscription? _ruchesUtilisateurSubscription;

void ecouterToutesRuches() {
  _ruchesUtilisateurSubscription = rucheService.ecouterRuchesUtilisateur()
    .listen(
      (List<Map<String, dynamic>> ruches) {
        setState(() {
          _toutesRuches = ruches;
        });
      },
      onError: (error) {
        print('Erreur: $error');
      },
    );
}
```

## Gestion d'erreurs

Le service gère automatiquement plusieurs types d'erreurs :

### Erreurs d'authentification
```dart
'Utilisateur non connecté. Veuillez vous connecter pour ajouter une ruche.'
```

### Erreurs de permissions
```dart
'Vous n\'êtes pas autorisé à ajouter une ruche dans ce rucher.'
'Accès non autorisé à cette ruche'
```

### Erreurs de données
```dart
'Le rucher spécifié n\'existe pas.'
'Ruche non trouvée'
'Impossible d\'ajouter une ruche dans un rucher inactif.'
```

### Erreurs Firebase
```dart
'Permissions insuffisantes pour créer une ruche'
'Service temporairement indisponible. Veuillez réessayer.'
'Service Firestore temporairement indisponible. Veuillez réessayer.'
```

## Bonnes pratiques

### 1. Gestion des erreurs dans l'UI
```dart
try {
  await rucheService.ajouterRuche(...);
  // Afficher un message de succès
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Ruche ajoutée avec succès')),
  );
} catch (e) {
  // Afficher l'erreur à l'utilisateur
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Erreur: $e')),
  );
}
```

### 2. Validation des entrées
```dart
String? _validerNomRuche(String? nom) {
  if (nom == null || nom.trim().isEmpty) {
    return 'Le nom de la ruche est requis';
  }
  if (nom.trim().length < 2) {
    return 'Le nom doit contenir au moins 2 caractères';
  }
  return null;
}
```

### 3. Chargement asynchrone
```dart
bool _isLoading = false;

Future<void> _ajouterRuche() async {
  setState(() => _isLoading = true);
  
  try {
    await rucheService.ajouterRuche(...);
  } catch (e) {
    // Gérer l'erreur
  } finally {
    setState(() => _isLoading = false);
  }
}
```

## Sécurité

### Règles Firestore requises

Pour que le service fonctionne correctement, assurez-vous que vos règles Firestore permettent :

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Règles pour les ruches
    match /ruches/{rucheId} {
      allow read, write: if request.auth != null 
        && resource.data.idApiculteur == request.auth.uid;
      allow create: if request.auth != null 
        && request.resource.data.idApiculteur == request.auth.uid;
    }
    
    // Règles pour les ruchers
    match /ruchers/{rucherId} {
      allow read: if request.auth != null 
        && resource.data.idApiculteur == request.auth.uid;
    }
  }
}
```

## Dépendances

Ce service nécessite les packages suivants dans `pubspec.yaml` :

```yaml
dependencies:
  firebase_auth: ^4.15.0
  cloud_firestore: ^4.13.0
  firebase_core: ^2.20.0
```

## Index Firestore recommandés

Pour optimiser les performances, créez ces index dans Firestore :

1. **Collection `ruches`**
   - `idRucher` (Ascending) + `actif` (Ascending) + `position` (Ascending)
   - `idApiculteur` (Ascending) + `actif` (Ascending) + `dateCreation` (Descending)

Ces index sont nécessaires pour les requêtes de tri et de filtrage utilisées par le service.

## Logging

Le service utilise `LoggerService` pour tracer les opérations :
- `info` : Opérations importantes
- `debug` : Détails de débogage
- `warning` : Situations anormales mais non critiques
- `error` : Erreurs avec stack trace

Consultez les logs pour diagnostiquer les problèmes :
```dart
LoggerService.info('🐝 Ruche créée avec succès. ID: $rucheId');
``` 