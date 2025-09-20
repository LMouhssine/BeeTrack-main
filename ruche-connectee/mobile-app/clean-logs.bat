@echo off
echo ========================================
echo NETTOYAGE DES LOGS DE L'APPLICATION
echo ========================================
echo.

echo 🧹 Nettoyage des fichiers temporaires...
flutter clean

echo.
echo 📦 Nettoyage du cache des dépendances...
flutter pub cache clean

echo.
echo 🔄 Réinstallation des dépendances...
flutter pub get

echo.
echo ✅ Nettoyage terminé !
echo L'application est prête à être utilisée.
echo.
pause






