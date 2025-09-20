@echo off
chcp 65001 >nul
echo.
echo ====================================================
echo    🚀 Redémarrage BeeTrack avec Firebase corrigé
echo ====================================================
echo.

cd /d "%~dp0"

echo 🔧 Configuration de la variable d'environnement Firebase...
set FIREBASE_API_KEY=AIzaSyBOo8k8r1m3a6N-eGOQ1C-2KOdOEn4Hq0e8
echo ✅ FIREBASE_API_KEY définie: %FIREBASE_API_KEY:~0,20%...

echo.
echo 🧹 Nettoyage et compilation...
mvn clean compile -q
if errorlevel 1 (
    echo ❌ Erreur de compilation!
    pause
    exit /b 1
)
echo ✅ Compilation réussie

echo.
echo 🚀 Démarrage de l'application...
echo.
echo ⏳ L'application va démarrer - attendez le message de succès...
echo.

mvn spring-boot:run

echo.
echo 📞 L'application s'est arrêtée. Vérifiez les logs ci-dessus.
pause
