# 🚀 BeeTrack CI/CD Pipeline

Cette configuration GitHub Actions fournit une pipeline complète CI/CD pour l'application mobile Flutter BeeTrack.

## 📋 Workflows Disponibles

### 1. `flutter-ci.yml` - Pipeline Principal
**Déclencheurs :** Push/PR sur `main` et `develop` (dossier mobile-app)

**Jobs :**
- ✅ **Test** : Tests unitaires, analyse statique, formatage
- 📱 **Build Android** : Génération d'APK de release
- 🌐 **Build Web** : Build pour déploiement web
- 🚀 **Deploy Web** : Déploiement automatique sur GitHub Pages

### 2. `release.yml` - Builds de Release
**Déclencheurs :** Création de release ou manuel

**Fonctionnalités :**
- 📱 Build APK et App Bundle Android
- 🌐 Build Web avec archive compressée
- 📦 Upload automatique des assets vers la release

### 3. `security.yml` - Analyse de Sécurité
**Déclencheurs :** Push/PR sur `main` + hebdomadaire

**Contrôles :**
- 🔍 Audit des dépendances Flutter (`dart pub audit`)
- 📊 Review des dépendances dans les PR
- 📋 Vérification des dépendances obsolètes
- 🛡️ Analyse statique de sécurité (`flutter analyze --fatal-infos`)

> **Note :** CodeQL n'est pas encore compatible avec Dart/Flutter. Nous utilisons les outils natifs Flutter pour l'analyse de sécurité.

## 🔧 Configuration Requise

### Permissions GitHub Pages
Pour activer le déploiement automatique :
1. Aller dans `Settings > Pages`
2. Source : `GitHub Actions`
3. Activer les permissions dans `Settings > Actions > General`

### Secrets (Optionnels)
Aucun secret requis pour le fonctionnement de base.

## 📊 Fonctionnalités

### ✅ Tests Automatisés
- Tests unitaires Flutter
- Analyse statique (`flutter analyze`)
- Vérification du formatage (`dart format`)

### 📱 Builds Multi-Plateformes
- **Android** : APK et App Bundle
- **Web** : Build optimisé pour production

### 🚀 Déploiement Automatique
- **GitHub Pages** : Déploiement web automatique sur push main
- **Releases** : Assets automatiquement attachés

### 🛡️ Sécurité
- Audit des dépendances hebdomadaire avec `dart pub audit`
- Analyse statique stricte du code Dart/Flutter
- Review des changements de dépendances dans les PR
- Vérification des dépendances obsolètes

## 📈 Monitoring

Les workflows génèrent des artifacts téléchargeables :
- `android-apk` : APK Android de release
- `web-build` : Build web complet

## 🔄 Workflow de Développement

1. **Développement** : Push sur branches feature
2. **Pull Request** : Tests automatiques + review
3. **Merge main** : Build complet + déploiement web
4. **Release** : Assets binaires générés automatiquement

## 🏃‍♂️ Démarrage Rapide

1. **Commit** cette configuration
2. **Push** vers GitHub
3. **Vérifier** l'onglet "Actions" dans votre repo
4. **Activer** GitHub Pages dans les settings

## 🔍 Debugging

En cas de problème :
- Vérifier les logs dans l'onglet "Actions"
- S'assurer que Flutter 3.24.x est compatible
- Vérifier les permissions GitHub Pages

## 🛡️ Sécurité Flutter

Notre pipeline utilise les outils de sécurité spécifiques à Flutter :
- **`dart pub audit`** : Détection des vulnérabilités dans les dépendances
- **`flutter analyze --fatal-infos`** : Analyse statique stricte
- **`flutter pub outdated`** : Suivi des mises à jour de sécurité 