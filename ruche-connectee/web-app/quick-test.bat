@echo off
chcp 65001 >nul
echo.
echo ==========================================
echo        ⚡ BeeTrack - Test Rapide
echo ==========================================
echo.

cd /d "%~dp0"

echo 🔍 Vérification de la configuration...
echo.

REM Vérifier application.properties
echo 📁 Configuration Firebase:
findstr "firebase.api-key" src\main\resources\application.properties
echo.

REM Vérifier la compilation
echo 🔨 Test de compilation...
mvn compile -q
if errorlevel 1 (
    echo ❌ Erreur de compilation!
    pause
    exit /b 1
)
echo ✅ Compilation réussie

echo.
echo ==========================================
echo        ✅ PRÊT POUR LE DÉMARRAGE
echo ==========================================
echo.
echo 🎯 Pour démarrer l'application:
echo    ./start-simple.bat
echo.
echo 🌐 Une fois démarrée, allez sur:
echo    http://localhost:8080/login
echo.
echo 💡 Vous devriez voir:
echo    "✅ Firebase configuré et actif"
echo.
pause
