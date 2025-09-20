@echo off
chcp 65001 >nul
echo.
echo ========================================
echo    🧹 Nettoyage des anciennes configs
echo ========================================
echo.

cd /d "%~dp0"

echo 🗑️ Suppression des fichiers de configuration complexes...

REM Sauvegarder les logs utiles
if exist output.log (
    copy output.log output_archive.log >nul 2>&1
    echo ✅ Logs sauvegardés dans output_archive.log
)

REM Supprimer les anciens scripts complexes
if exist configure-firebase.bat del configure-firebase.bat >nul 2>&1
if exist configure-firebase-api.bat del configure-firebase-api.bat >nul 2>&1
if exist restart-with-firebase.bat del restart-with-firebase.bat >nul 2>&1
if exist test-firebase-config.bat del test-firebase-config.bat >nul 2>&1
if exist diagnostic-firebase.bat del diagnostic-firebase.bat >nul 2>&1
if exist start-firebase.bat del start-firebase.bat >nul 2>&1

REM Supprimer les guides complexes
if exist firebase-config.example del firebase-config.example >nul 2>&1
if exist OBTENIR_CLE_API_FIREBASE.md del OBTENIR_CLE_API_FIREBASE.md >nul 2>&1
if exist RESOLUTION_CLE_API_FIREBASE.md del RESOLUTION_CLE_API_FIREBASE.md >nul 2>&1
if exist TEST_AUTHENTIFICATION.md del TEST_AUTHENTIFICATION.md >nul 2>&1
if exist GUIDE_AUTHENTIFICATION_FIREBASE.md del GUIDE_AUTHENTIFICATION_FIREBASE.md >nul 2>&1
if exist GUIDE_LOGIN_FIREBASE.md del GUIDE_LOGIN_FIREBASE.md >nul 2>&1

echo ✅ Nettoyage terminé!
echo.
echo 📁 Fichiers conservés:
echo - start-simple.bat (script de démarrage)
echo - SIMPLE_START.md (guide simplifié)
echo - application.properties (configuration directe)
echo - output_archive.log (logs sauvegardés)
echo.
echo 🎯 Utilisation: ./start-simple.bat
echo.
pause
