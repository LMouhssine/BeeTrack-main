@echo off
echo ============================================
echo    Correction des dependances Flutter
echo ============================================

echo.
echo 1. Nettoyage du cache Flutter...
flutter clean

echo.
echo 2. Mise a jour de Flutter...
flutter upgrade --force

echo.
echo 3. Configuration Flutter sans analytics...
flutter config --no-analytics

echo.
echo 4. Verification de la configuration Flutter...
flutter doctor -v

echo.
echo 5. Recuperation des dependances...
flutter pub get

echo.
echo 6. Mise a jour des dependances...
flutter pub upgrade

echo.
echo 7. Resolution des conflits...
flutter pub deps

echo.
echo 8. Verification finale...
flutter analyze

echo.
echo ============================================
echo    Correction terminee !
echo ============================================
echo.
echo Vous pouvez maintenant lancer l'application avec :
echo flutter run
echo.
pause