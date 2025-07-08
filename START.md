# 🚀 Démarrage rapide BeeTrack

## ⚡ Commandes essentielles

### Démarrer l'application
```powershell
# Aller dans le bon répertoire
cd ruche-connectee/web-app

# Démarrer l'application Spring Boot
mvn spring-boot:run
```

### Accéder à l'application
- **Dashboard** : http://localhost:8080/dashboard
- **Test Firebase** : http://localhost:8080/test

## 🔧 Commandes utiles

```powershell
# Tests
mvn test

# Build de production
mvn clean package

# Mode développement
mvn spring-boot:run -Dspring.profiles.active=dev

# Mode debug
mvn spring-boot:run -Dagentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=5005
```

## 📋 Checklist rapide

- [ ] Java 17+ installé
- [ ] Maven installé
- [ ] Fichier `firebase-service-account.json` dans `src/main/resources/`
- [ ] Port 8080 disponible

## 📚 Documentation complète

- **Guide utilisateur** : `docs/utilisateur/GUIDE_UTILISATEUR_WEB.md`
- **Guide développeur** : `docs/developpement/GUIDE_SPRING_BOOT.md`
- **Documentation complète** : `docs/README.md`

---

**BeeTrack - Version Spring Boot + Thymeleaf** 🐝 