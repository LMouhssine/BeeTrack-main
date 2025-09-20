# 🔥 Guide Firebase Realtime Database - Dashboard

## 📊 **Structure Firebase détectée**

D'après votre arborescence Firebase Realtime Database :

```
rucheconnecteeesp32-default-rtdb.europe-west1.firebasedatabase.app/
├── apiculteurs/          # Apiculteurs
├── details/              # Détails
├── mesures/              # Mesures des capteurs
│   ├── -0VxGf1-dR71gWXJX1sq/
│   │   ├── couvercleOuvert: false
│   │   ├── humidite: 65
│   │   ├── humiditeNormale: true
│   │   ├── id: "-OVxGf1-dR7IgWXJXlsq"
│   │   ├── poids: 45.2
│   │   ├── rucheId: "-OVxGf0UweNJJHSGI6z3"
│   │   ├── temperature: 24.5
│   │   ├── temperatureNormale: false
│   │   └── timestamp: "2025-07-24T18:31:39.5267753"
│   └── -0VxGf1Ge4LdKuA8JdDK/
├── ruche/                # Ruche (singulier)
├── ruchers/              # Ruchers
└── ruches/               # Ruches (pluriel)
```

## ✅ **Configuration réalisée**

### 1. **Service DashboardDataService**
- ✅ Créé `DashboardDataService.java`
- ✅ Adapté à votre structure Firebase Realtime Database
- ✅ Récupère les données des collections : `ruches`, `ruchers`, `mesures`

### 2. **Contrôleur WebController modifié**
- ✅ Intégré le nouveau service
- ✅ Récupère les statistiques depuis Firebase
- ✅ Affiche les mesures récentes

### 3. **Template Dashboard adapté**
- ✅ Affichage des ruches si disponibles
- ✅ Affichage des mesures si pas de ruches
- ✅ Gestion des cas vides

### 4. **APIs de test créées**
- ✅ `FirebaseTestController` (avec authentification)
- ✅ `SimpleTestController` (sans authentification)

## 🚀 **Comment tester**

### Option 1: Test direct des APIs

```bash
# Test simple
curl http://localhost:8080/test-api/ping

# Test des mesures
curl http://localhost:8080/test-api/mesures

# Test des ruches
curl http://localhost:8080/test-api/ruches

# Test des ruchers
curl http://localhost:8080/test-api/ruchers

# Test complet
curl http://localhost:8080/test-api/complete
```

### Option 2: Via PowerShell

```powershell
# Test de base
Invoke-WebRequest -Uri "http://localhost:8080/test-api/ping"

# Test des mesures
Invoke-WebRequest -Uri "http://localhost:8080/test-api/mesures"

# Test complet
Invoke-WebRequest -Uri "http://localhost:8080/test-api/complete"
```

### Option 3: Via navigateur

1. **Démarrer l'application** :
   ```bash
   cd ruche-connectee/web-app
   mvn spring-boot:run
   ```

2. **Tester les URLs** :
   - http://localhost:8080/test-api/ping
   - http://localhost:8080/test-api/mesures
   - http://localhost:8080/test-api/ruches
   - http://localhost:8080/test-api/complete

## 🔧 **Résolution des problèmes**

### Problème: Redirection vers login

Si vous êtes redirigé vers la page de connexion :

1. **Utiliser les APIs de test** (sans authentification) :
   - `/test-api/ping`
   - `/test-api/mesures`
   - `/test-api/ruches`

2. **Ou se connecter avec les identifiants de test** :
   - Email: `admin@beetrackdemo.com`
   - Mot de passe: `admin123`

### Problème: Erreur Firebase

Si vous obtenez des erreurs Firebase :

1. **Vérifier la configuration** :
   ```properties
   # application.properties
   firebase.project-id=rucheconnecteeesp32
   firebase.credentials-path=firebase-service-account.json
   firebase.database-url=https://rucheconnecteeesp32-default-rtdb.europe-west1.firebasedatabase.app
   ```

2. **Vérifier le fichier de credentials** :
   - Emplacement: `ruche-connectee/web-app/src/main/resources/firebase-service-account.json`
   - Contenu: Doit contenir les bonnes clés pour `rucheconnecteeesp32`

### Problème: Données vides

Si les APIs retournent des données vides :

1. **Vérifier Firebase Console** :
   - Aller sur https://console.firebase.google.com/
   - Sélectionner le projet `rucheconnecteeesp32`
   - Vérifier Realtime Database
   - Confirmer que les données sont présentes

2. **Vérifier les règles de sécurité** :
   - Dans Firebase Console → Realtime Database → Règles
   - S'assurer que les règles permettent la lecture

## 📈 **Données attendues**

### Réponse API Mesures
```json
{
  "status": "SUCCESS",
  "message": "Mesures récupérées avec succès",
  "count": 2,
  "data": [
    {
      "id": "-0VxGf1-dR71gWXJX1sq",
      "couvercleOuvert": false,
      "humidite": 65,
      "humiditeNormale": true,
      "poids": 45.2,
      "rucheId": "-OVxGf0UweNJJHSGI6z3",
      "temperature": 24.5,
      "temperatureNormale": false,
      "timestamp": "2025-07-24T18:31:39.5267753"
    }
  ]
}
```

### Réponse API Dashboard Stats
```json
{
  "status": "SUCCESS",
  "data": {
    "totalRuches": 1,
    "totalRuchers": 1,
    "ruchesEnService": 1,
    "alertesActives": 0,
    "temperatureMoyenne": 24.5,
    "humiditeMoyenne": 65.0
  }
}
```

## 🎯 **Prochaines étapes**

1. **Tester les APIs** pour confirmer la connexion Firebase
2. **Vérifier les données** dans Firebase Console
3. **Accéder au dashboard** via http://localhost:8080/dashboard
4. **Ajouter des données** si nécessaire via Firebase Console

## 📞 **Support**

Si vous rencontrez des problèmes :

1. **Vérifier les logs** de l'application Spring Boot
2. **Tester les APIs** de test
3. **Vérifier Firebase Console** pour les données
4. **Consulter** la documentation de dépannage

---

**🎉 Votre dashboard est maintenant configuré pour fonctionner avec Firebase Realtime Database !** 