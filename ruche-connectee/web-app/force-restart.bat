@echo off
chcp 65001 >nul
echo.
echo ==========================================
echo      🔄 Redémarrage Forcé - BeeTrack
echo ==========================================
echo.

cd /d "%~dp0"

echo 🛑 Arrêt de tous les processus Java (si en cours)...
taskkill /f /im java.exe >nul 2>&1
timeout /t 2 >nul

echo.
echo 🧹 Nettoyage complet des caches...
REM Supprimer le dossier target
if exist target (
    rmdir /s /q target >nul 2>&1
    echo ✅ Cache Maven supprimé
)

REM Nettoyer Maven
mvn clean -q
echo ✅ Projet nettoyé

echo.
echo 🔧 Vérification de la configuration Firebase...
echo Configuration actuelle:
findstr "firebase.api-key" src\main\resources\application.properties
echo.

echo 🔨 Recompilation complète...
mvn compile -q
if errorlevel 1 (
    echo ❌ Erreur de compilation!
    pause
    exit /b 1
)
echo ✅ Compilation réussie

echo.
echo ==========================================
echo     🚀 DÉMARRAGE AVEC NOUVELLE CONFIG
echo ==========================================
echo.
echo ⏳ Démarrage en cours... Attendez "Started BeeTrackApplication"
echo 📱 Une fois démarré, allez sur: http://localhost:8080/login
echo.

mvn spring-boot:run

echo.
echo 📞 Application arrêtée.
pause
