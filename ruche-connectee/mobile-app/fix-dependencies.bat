@echo off
echo ============================================
echo    Correction des dependances Flutter
echo ============================================

echo.
echo 1. Verification de la version Flutter...
flutter --version

echo.
echo 2. Configuration Flutter sans analytics...
flutter config --no-analytics

echo.
echo 3. Nettoyage complet du cache Flutter...
flutter clean
if exist "pubspec.lock" del "pubspec.lock"
if exist ".dart_tool" rmdir /s /q ".dart_tool"

echo.
echo 4. Verification de la configuration Flutter...
flutter doctor -v

echo.
echo 5. Recuperation des dependances avec versions compatibles...
flutter pub get

echo.
echo 6. Verification des dependances...
flutter pub deps

echo.
echo 7. Test d'analyse du code...
flutter analyze --no-fatal-infos

echo.
echo 8. Test de compilation...
flutter build apk --debug

echo.
echo ============================================
echo    Correction terminee !
echo ============================================
echo.
echo Versions compatibles installees :
echo - go_router: ^14.2.7 (compatible Dart 3.5.4)
echo - flutter_lints: ^4.0.0 (compatible Dart 3.5.4)
echo - Firebase: versions compatibles
echo.
echo Vous pouvez maintenant lancer l'application avec :
echo flutter run
echo.
pause