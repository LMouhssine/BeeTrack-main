# 🧪 Guide de Test - Application Web BeeTrack

## 🚀 Lancement Rapide

### 1. Démarrer l'Application
```bash
cd ruche-connectee/web-app
mvn spring-boot:run
```

### 2. Accéder à l'Interface
- **URL** : http://localhost:8080
- **Port** : 8080 (par défaut)

## 🎯 Test de l'Interface Web

### Étape 1: Premier Accès
1. **Ouvrir** http://localhost:8080 dans votre navigateur
2. **Entrer votre ID apiculteur** Firebase (ex: `7USxTi7lFhPPhkbxHNvUD7Et1yt2`)
3. **Vérifier** que l'interface se charge correctement

### Étape 2: Créer un Rucher
1. **Cliquer** sur "Ajouter un Rucher"
2. **Remplir le formulaire** :
   - **Nom** : "Rucher Web Test"
   - **Adresse** : "123 Rue du Web, 75001 Paris"
   - **Description** : "Rucher créé depuis l'interface web"
   - **ID Apiculteur** : (pré-rempli)
3. **Cliquer** "Créer le Rucher"
4. **Vérifier** le message de succès
5. **Confirmer** que le rucher apparaît dans la liste

### Étape 3: Gestion des Ruchers
1. **Voir la liste** des ruchers existants
2. **Tester la suppression** d'un rucher
3. **Confirmer** la suppression

## 🔄 Test de Synchronisation Mobile/Web

### Test Bidirectionnel

#### Web → Mobile
1. **Créer un rucher** depuis l'interface web
2. **Ouvrir l'app mobile** Flutter
3. **Vérifier** que le rucher apparaît dans l'app mobile

#### Mobile → Web
1. **Créer un rucher** depuis l'app mobile Flutter
2. **Rafraîchir** l'interface web (F5)
3. **Vérifier** que le rucher apparaît dans l'interface web

## 🔗 Test des Endpoints API

### Endpoints Web Standards
```bash
# Lister les ruchers d'un apiculteur
curl -X GET "http://localhost:8080/api/ruchers/apiculteur/VOTRE_ID"

# Créer un rucher (format web)
curl -X POST "http://localhost:8080/api/ruchers" \
  -H "Content-Type: application/json" \
  -d '{
    "nom": "Test API",
    "adresse": "123 API Street",
    "description": "Test depuis API",
    "apiculteurId": "VOTRE_ID"
  }'
```

### Endpoints Compatibilité Mobile
```bash
# Créer un rucher (format mobile)
curl -X POST "http://localhost:8080/api/ruchers/mobile" \
  -H "Content-Type: application/json" \
  -d '{
    "nom": "Test Mobile API",
    "adresse": "123 Mobile Street",
    "description": "Test format mobile",
    "idApiculteur": "VOTRE_ID"
  }'

# Lister au format mobile
curl -X GET "http://localhost:8080/api/ruchers/mobile/apiculteur/VOTRE_ID"
```

## 📱 Test Responsive

### Desktop
- **Résolution** : 1920x1080
- **Vérifier** : Navigation horizontale, grille 3 colonnes

### Tablette
- **Résolution** : 768x1024
- **Vérifier** : Navigation adaptée, grille 2 colonnes

### Mobile
- **Résolution** : 375x667
- **Vérifier** : Navigation verticale, grille 1 colonne

## ✅ Checklist de Test

### Interface Utilisateur
- [ ] **Chargement** : Page se charge en < 3 secondes
- [ ] **Navigation** : Onglets fonctionnent correctement
- [ ] **Formulaire** : Validation et soumission OK
- [ ] **Notifications** : Messages de succès/erreur affichés
- [ ] **Responsive** : Fonctionne sur mobile/tablette/desktop

### Fonctionnalités
- [ ] **Création** : Nouveau rucher créé avec succès
- [ ] **Affichage** : Liste des ruchers visible
- [ ] **Suppression** : Rucher supprimé avec confirmation
- [ ] **Persistance** : Données sauvées en base
- [ ] **Synchronisation** : Compatible avec app mobile

### API
- [ ] **Endpoints web** : Réponses correctes
- [ ] **Endpoints mobile** : Format compatible
- [ ] **Gestion erreurs** : Messages d'erreur appropriés
- [ ] **CORS** : Pas de problèmes cross-origin

## 🐛 Problèmes Courants

### Erreur de Connexion
```
Erreur: Failed to fetch
```
**Solution** : Vérifier que l'application Spring Boot est démarrée

### ID Apiculteur Invalide
```
Erreur: Aucun rucher trouvé
```
**Solution** : Utiliser un ID Firebase valide existant

### Problème CORS
```
Erreur: CORS policy
```
**Solution** : Vérifier la configuration `@CrossOrigin` dans les contrôleurs

## 📊 Données de Test

### Ruchers d'Exemple
```json
[
  {
    "nom": "Rucher Principal",
    "adresse": "123 Rue des Abeilles, 75001 Paris",
    "description": "Rucher principal avec 10 ruches actives"
  },
  {
    "nom": "Rucher Secondaire",
    "adresse": "456 Avenue du Miel, 69000 Lyon",
    "description": "Rucher d'expansion pour la saison"
  },
  {
    "nom": "Rucher de Test",
    "adresse": "789 Boulevard des Tests, 13000 Marseille",
    "description": "Rucher utilisé pour les tests de l'application"
  }
]
```

## 🎯 Résultats Attendus

### Après Test Complet
1. ✅ **Interface fonctionnelle** sur tous les appareils
2. ✅ **Ruchers créés** visibles dans les deux applications
3. ✅ **Synchronisation** bidirectionnelle opérationnelle
4. ✅ **API** répondant correctement
5. ✅ **Expérience utilisateur** fluide et intuitive

## 🚀 Prochaines Étapes

Après validation des tests :
1. **Déploiement** en environnement de production
2. **Formation** des utilisateurs
3. **Monitoring** des performances
4. **Développement** des fonctionnalités avancées

---

**Note** : L'application web est maintenant prête et compatible avec l'application mobile Flutter ! 🎉 