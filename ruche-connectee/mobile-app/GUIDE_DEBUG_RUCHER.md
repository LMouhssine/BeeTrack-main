# Guide de Débogage - Problème d'Ajout de Rucher

## 🔍 Diagnostic du Problème

Vous êtes connecté avec succès (utilisateur ID: `7USxTi7lFhPPhkbxHNvUD7Et1yt2`) mais ne pouvez pas ajouter un rucher. Voici les étapes pour identifier et résoudre le problème.

## ✅ Corrections Apportées

1. **Route ajoutée** : `/ruchers/ajouter` → `AjouterRucherScreen`
2. **RucherListScreen mis à jour** : Utilise maintenant le `RucherService` avec StreamBuilder
3. **Navigation ajoutée** : Boutons pour accéder à l'écran d'ajout
4. **Écran de test créé** : `/test` pour tester le service directement

## 🚀 Comment Tester

### Option 1: Interface Normale
1. Allez sur l'écran "Mes Ruchers" (onglet principal)
2. Cliquez sur le bouton "+" dans l'AppBar ou le FloatingActionButton
3. Remplissez le formulaire et cliquez "Créer le rucher"

### Option 2: Écran de Test
1. Naviguez vers `/test` dans votre app
2. Cliquez sur "Tester Ajouter Rucher"
3. Observez les logs et le résultat

## 🔧 Étapes de Débogage

### 1. Vérifier la Navigation
```dart
// Dans votre app, essayez de naviguer manuellement vers:
context.go('/ruchers/ajouter');
// ou
context.go('/test');
```

### 2. Vérifier les Logs
Recherchez dans les logs Flutter :
```
💡 Tentative d'ajout d'un nouveau rucher: [nom]
💡 Utilisateur connecté: 7USxTi7lFhPPhkbxHNvUD7Et1yt2
💡 Données du rucher à créer: {...}
💡 Rucher créé avec succès. ID: [id]
```

### 3. Vérifier les Permissions Firestore
Assurez-vous que vos règles Firestore permettent l'écriture :
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /ruchers/{rucherId} {
      allow read, write: if request.auth != null;
      allow create: if request.auth != null;
    }
  }
}
```

### 4. Vérifier la Structure des Données
Le service crée des documents avec cette structure :
```json
{
  "idApiculteur": "7USxTi7lFhPPhkbxHNvUD7Et1yt2",
  "nom": "Nom du rucher",
  "adresse": "Adresse complète",
  "description": "Description",
  "dateCreation": "timestamp_firestore",
  "actif": true,
  "nombreRuches": 0
}
```

## 🐛 Erreurs Possibles et Solutions

### Erreur: "Utilisateur non connecté"
**Cause**: L'utilisateur Firebase Auth n'est pas disponible
**Solution**: Vérifiez que `FirebaseAuth.instance.currentUser` n'est pas null

### Erreur: "Permission denied"
**Cause**: Règles Firestore trop restrictives
**Solution**: Mettez à jour les règles Firestore (voir section 3)

### Erreur: "Service unavailable"
**Cause**: Problème de connectivité ou Firebase
**Solution**: Vérifiez la connexion internet et le statut Firebase

### Erreur: Navigation ne fonctionne pas
**Cause**: Route non définie ou import manquant
**Solution**: Vérifiez que toutes les routes sont bien définies dans `router.dart`

## 📱 Test Rapide

Ajoutez ce code temporaire dans votre `HomeScreen` pour un test rapide :

```dart
FloatingActionButton(
  onPressed: () async {
    try {
      final rucherService = RucherService(GetIt.I<FirebaseService>());
      final id = await rucherService.ajouterRucher(
        nom: 'Test ${DateTime.now().millisecondsSinceEpoch}',
        adresse: 'Test Address',
        description: 'Test Description',
      );
      print('✅ Rucher créé: $id');
    } catch (e) {
      print('❌ Erreur: $e');
    }
  },
  child: Icon(Icons.bug_report),
)
```

## 🔍 Vérifications Console Firebase

1. Allez sur [Firebase Console](https://console.firebase.google.com)
2. Sélectionnez votre projet `ruche-connectee-93eab`
3. Allez dans Firestore Database
4. Vérifiez si la collection `ruchers` existe
5. Vérifiez les règles de sécurité

## 📋 Checklist de Vérification

- [ ] L'utilisateur est bien connecté (ID visible dans les logs)
- [ ] La route `/ruchers/ajouter` est accessible
- [ ] Le formulaire s'affiche correctement
- [ ] Les champs sont validés
- [ ] Le bouton "Créer le rucher" est cliquable
- [ ] Les logs montrent la tentative d'ajout
- [ ] Firestore est accessible depuis l'app
- [ ] Les règles Firestore permettent l'écriture

## 🆘 Si le Problème Persiste

1. **Testez l'écran de test** : `/test`
2. **Vérifiez les logs complets** dans la console Flutter
3. **Testez avec des données simples** (nom court, adresse simple)
4. **Vérifiez la console Firebase** pour les erreurs côté serveur
5. **Redémarrez l'application** complètement

## 📞 Informations de Debug à Fournir

Si le problème persiste, fournissez :
- Les logs complets de la tentative d'ajout
- Le message d'erreur exact (si affiché)
- La version de Flutter utilisée
- L'état de la console Firebase (erreurs visibles ?)

---

**Note**: Toutes les corrections ont été appliquées. L'interface devrait maintenant fonctionner correctement pour ajouter des ruchers. 