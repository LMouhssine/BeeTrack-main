# Résolution des Erreurs Firebase Permissions

## 🚨 Problème

**Erreur :** `[cloud_firestore/permission-denied] Missing or insufficient permissions`

**Cause :** Les règles de sécurité Firestore sont trop restrictives ou mal configurées.

## ✅ Solution

### 1. Déployer les Règles Firestore

#### Étape 1 : Accéder à Firebase Console
1. Aller sur [Firebase Console](https://console.firebase.google.com/)
2. Sélectionner le projet : `ruche-connectee-93eab`

#### Étape 2 : Configurer les Règles
1. Dans le menu, aller à **Firestore Database**
2. Cliquer sur l'onglet **Règles**
3. Remplacer le contenu par :

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Règles pour la collection apiculteurs
    match /apiculteurs/{apiculteurId} {
      allow read, write: if request.auth != null && request.auth.uid == apiculteurId;
      allow read: if request.auth != null;
    }
    
    // Règles pour la collection ruchers
    match /ruchers/{rucherId} {
      allow read, write: if request.auth != null && 
        (resource.data.idApiculteur == request.auth.uid || 
         request.auth.token.email == 'admin@beetrackdemo.com');
      allow read: if request.auth != null;
    }
    
    // Règles pour la collection ruches
    match /ruches/{rucheId} {
      allow read, write: if request.auth != null && 
        (resource.data.idApiculteur == request.auth.uid || 
         request.auth.token.email == 'admin@beetrackdemo.com');
      allow read: if request.auth != null;
    }
    
    // Règles pour la collection donneesCapteurs
    match /donneesCapteurs/{donneeId} {
      allow read, write: if request.auth != null && 
        (resource.data.idApiculteur == request.auth.uid || 
         request.auth.token.email == 'admin@beetrackdemo.com');
      allow read: if request.auth != null;
    }
    
    // Règles temporaires pour le développement
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

#### Étape 3 : Publier les Règles
1. Cliquer sur **Publier**
2. Attendre la confirmation de déploiement

### 2. Vérifier l'Authentification

#### Configuration Flutter
Le fichier `firebase_options.dart` doit contenir :
```dart
static const FirebaseOptions web = FirebaseOptions(
  apiKey: "YOUR_API_KEY", // Remplacer par votre clé API
  authDomain: "your-project-id.firebaseapp.com",
  projectId: "your-project-id",
  storageBucket: "your-project-id.firebasestorage.app",
  messagingSenderId: "YOUR_MESSAGING_SENDER_ID",
  appId: "YOUR_APP_ID",
);
```

⚠️ **SÉCURITÉ**: Ne jamais committer de vraies clés API dans le code source !

### 3. Activer l'Authentification Firebase

#### Étape 1 : Activer Auth
1. Dans Firebase Console, aller à **Authentication**
2. Cliquer sur **Get started**
3. Aller dans l'onglet **Sign-in method**
4. Activer **Email/Password**

#### Étape 2 : Créer un Utilisateur Test
1. Dans **Authentication > Users**
2. Cliquer sur **Add user**
3. Créer l'utilisateur :
   - Email : `jean.dupont@email.com`
   - Mot de passe : `Azerty123`

### 4. Tester l'Application

#### Test Flutter
```bash
cd ruche-connectee/mobile-app
flutter run
```

#### Identifiants de Test
- **Email :** `jean.dupont@email.com`
- **Mot de passe :** `Azerty123`
- **Admin :** `admin@beetrackdemo.com` / `admin123`

## 🔧 Dépannage

### Erreurs Courantes

#### 1. "Missing or insufficient permissions"
**Solution :** Déployer les règles Firestore ci-dessus

#### 2. "Firebase not initialized"
**Solution :** Vérifier `firebase_options.dart`

#### 3. "Authentication failed"
**Solution :** Activer Email/Password dans Firebase Auth

### Vérifications

#### ✅ Configuration Firebase
- [ ] Projet ID correct : `your-project-id`
- [ ] API Key valide (ne pas exposer dans le code)
- [ ] Auth Domain correct

#### ✅ Règles Firestore
- [ ] Règles déployées
- [ ] Permissions appropriées
- [ ] Authentification requise

#### ✅ Authentification
- [ ] Email/Password activé
- [ ] Utilisateur test créé
- [ ] Identifiants corrects

## 🚀 Résultat Attendu

Après ces corrections :
- ✅ L'application Flutter se connecte sans erreur
- ✅ L'authentification fonctionne
- ✅ Les données Firestore sont accessibles
- ✅ L'interface s'affiche correctement

---

*Ces règles sont configurées pour le développement. En production, renforcer la sécurité selon les besoins.* 