# Guide de contribution

Merci de votre intérêt pour contribuer au projet Ruche Connectée ! Ce document fournit des lignes directrices pour contribuer efficacement au projet.

## 🌟 Comment contribuer

1. **Fork** le dépôt
2. **Créez une branche** pour votre fonctionnalité (`git checkout -b feature/amazing-feature`)
3. **Committez** vos changements (`git commit -m 'Add some amazing feature'`)
4. **Poussez** vers la branche (`git push origin feature/amazing-feature`)
5. Ouvrez une **Pull Request**

## 📋 Processus de développement

### Branches

- `main` : code de production stable
- `develop` : branche de développement principale
- `feature/*` : nouvelles fonctionnalités
- `bugfix/*` : corrections de bugs
- `release/*` : préparation des versions

### Commits

Utilisez des messages de commit clairs et descriptifs en suivant la convention :
```
type(scope): description courte

Description détaillée si nécessaire
```

Types : `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`

### Tests

Assurez-vous que tous les tests passent avant de soumettre une PR :
- Tests unitaires pour le backend
- Tests de widgets pour Flutter
- Vérification du code Arduino

## 🔍 Revue de code

Chaque PR sera examinée par au moins un mainteneur du projet. Les commentaires doivent être adressés avant la fusion.

## 📱 Directives spécifiques

### Application mobile (Flutter)
- Suivez les principes de Material Design
- Utilisez le pattern BLoC pour la gestion d'état
- Documentez les widgets personnalisés

### Backend (Spring Boot)
- Suivez les principes SOLID
- Documentez les API avec Swagger
- Écrivez des tests unitaires pour chaque service

### Module IoT (ESP32)
- Optimisez la consommation d'énergie
- Commentez le code de manière détaillée
- Gérez correctement les erreurs et les cas limites

## 🛠️ Environnement de développement

### Configuration recommandée
- **IDE** : Android Studio / IntelliJ IDEA / VS Code
- **Flutter** : dernière version stable
- **Java** : JDK 17+
- **Arduino IDE** : dernière version

## 📞 Contact

Pour toute question, n'hésitez pas à ouvrir une issue ou à contacter les mainteneurs du projet.

Merci de contribuer à améliorer la vie des apiculteurs avec notre système de ruches connectées !