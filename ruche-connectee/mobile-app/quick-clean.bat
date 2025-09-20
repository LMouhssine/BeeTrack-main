@echo off
echo ========================================
echo NETTOYAGE RAPIDE DES LOGS
echo ========================================
echo.

echo 🧹 Nettoyage rapide...
flutter clean

echo.
echo 📦 Réinstallation des dépendances...
flutter pub get

echo.
echo ✅ Nettoyage terminé !
echo.
pause






