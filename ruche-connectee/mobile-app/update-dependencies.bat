@echo off
echo ========================================
echo MISE A JOUR DES DEPENDANCES
echo ========================================
echo.

echo 🔄 Mise à jour des dépendances Flutter...
flutter pub upgrade

echo.
echo 📦 Mise à jour des dépendances majeures...
flutter pub upgrade --major-versions

echo.
echo 🧹 Nettoyage après mise à jour...
flutter clean

echo.
echo 📱 Réinstallation des dépendances...
flutter pub get

echo.
echo 🔍 Vérification des erreurs...
flutter analyze

echo.
echo ✅ Mise à jour terminée !
echo.
pause






