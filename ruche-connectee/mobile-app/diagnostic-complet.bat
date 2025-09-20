@echo off
echo ========================================
echo DIAGNOSTIC COMPLET DE L'APPLICATION
echo ========================================
echo.

echo 🔍 Vérification de l'environnement Flutter...
flutter doctor

echo.
echo 📦 Vérification des dépendances...
flutter pub deps

echo.
echo 🧹 Nettoyage complet...
flutter clean

echo.
echo 📱 Réinstallation des dépendances...
flutter pub get

echo.
echo 🔍 Analyse du code...
flutter analyze

echo.
echo 🚀 Test de compilation...
flutter build apk --debug

echo.
echo ✅ Diagnostic terminé !
echo.
pause






