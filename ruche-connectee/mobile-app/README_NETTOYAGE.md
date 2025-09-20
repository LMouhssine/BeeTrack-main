# 🧹 Nettoyage des Logs de l'Application Mobile

## Scripts de Nettoyage Disponibles

### 1. `quick-clean.bat` - Nettoyage Rapide
- **Usage** : Double-clic ou `.\quick-clean.bat`
- **Action** : Nettoyage rapide avec `flutter clean` et `flutter pub get`
- **Temps** : ~30 secondes
- **Recommandé pour** : Nettoyage quotidien

### 2. `clean-logs.bat` - Nettoyage Complet
- **Usage** : Double-clic ou `.\clean-logs.bat`
- **Action** : Nettoyage complet avec cache des dépendances
- **Temps** : ~1-2 minutes
- **Recommandé pour** : Nettoyage hebdomadaire ou après des erreurs

## Configuration des Logs

### Fichier de Configuration : `lib/config/logging_config.dart`

```dart
class LoggingConfig {
  // Désactiver les logs de debug en production
  static const bool enableDebugLogs = false;
  
  // Mode production (logs limités)
  static const bool productionMode = true;
  
  // Contrôler les types de logs
  static const bool showHttpDetails = false;
  static const bool showFirebaseLogs = true;
  static const bool showAuthLogs = true;
  static const bool showApiLogs = true;
}
```

### Niveaux de Log

- **Production** : Seuls les warnings et erreurs sont affichés
- **Développement** : Tous les logs info sont affichés
- **Debug** : Désactivé par défaut

## Quand Utiliser le Nettoyage

### ✅ Nettoyage Rapide (`quick-clean.bat`)
- Après des modifications de code
- Avant de tester l'application
- Nettoyage quotidien

### ✅ Nettoyage Complet (`clean-logs.bat`)
- Après des erreurs de compilation
- Changement de dépendances
- Nettoyage hebdomadaire
- Avant de déployer

## Commandes Manuelles

Si vous préférez les commandes manuelles :

```bash
# Nettoyage rapide
flutter clean
flutter pub get

# Nettoyage complet
flutter clean
flutter pub cache clean
flutter pub get
```

## Résolution des Problèmes

### Erreur "Build failed"
1. Exécuter `clean-logs.bat`
2. Redémarrer l'IDE
3. Vérifier les dépendances

### Logs trop verbeux
1. Modifier `lib/config/logging_config.dart`
2. Changer `productionMode = true`
3. Redémarrer l'application

### Cache corrompu
1. Exécuter `clean-logs.bat`
2. Supprimer le dossier `.dart_tool/`
3. Redémarrer l'IDE

## Maintenance

- **Quotidien** : `quick-clean.bat`
- **Hebdomadaire** : `clean-logs.bat`
- **Mensuel** : Vérifier les dépendances obsolètes
- **Avant déploiement** : Nettoyage complet obligatoire

---

*Dernière mise à jour : ${new Date().toLocaleDateString()}*






