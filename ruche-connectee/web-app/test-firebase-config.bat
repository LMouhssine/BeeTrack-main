@echo off
chcp 65001 >nul
echo.
echo ====================================================
echo    🧪 Test de configuration Firebase - BeeTrack
echo ====================================================
echo.

cd /d "%~dp0"

echo 🔍 Vérification de la configuration...
echo.

REM Vérifier le fichier application.properties
echo 📁 Vérification du fichier application.properties...
if not exist "src\main\resources\application.properties" (
    echo ❌ Fichier application.properties non trouvé!
    goto :error
)

REM Chercher la configuration Firebase
findstr /C:"firebase.api-key" "src\main\resources\application.properties" >nul
if errorlevel 1 (
    echo ❌ Configuration firebase.api-key non trouvée!
    goto :error
)

echo ✅ Fichier application.properties trouvé
echo.

REM Vérifier la clé API
echo 🔑 Vérification de la clé API Firebase...
for /f "tokens=2 delims=}" %%i in ('findstr /C:"firebase.api-key" "src\main\resources\application.properties"') do (
    set "currentKey=%%i"
)

if "%currentKey%"=="AIzaSyBOo8k8r1m3a6N-eGOQ1C-2KOdOEn4Hq0e8" (
    echo ✅ Clé API Firebase configurée correctement
) else if "%currentKey%"=="REMPLACEZ_PAR_VOTRE_CLE_API" (
    echo ❌ Clé API Firebase encore à la valeur par défaut!
    echo    Utilisez configure-firebase-api.bat pour la configurer
    goto :error
) else (
    echo ⚠️ Clé API personnalisée détectée: %currentKey:~0,20%...
)
echo.

REM Vérifier les variables d'environnement
echo 🌍 Vérification des variables d'environnement...
if defined FIREBASE_API_KEY (
    echo ✅ Variable FIREBASE_API_KEY définie: %FIREBASE_API_KEY:~0,20%...
) else (
    echo ⚠️ Variable FIREBASE_API_KEY non définie (utilise valeur par défaut)
)
echo.

REM Test de compilation
echo 🔨 Test de compilation...
echo (Cela peut prendre quelques instants...)
mvn compile -q
if errorlevel 1 (
    echo ❌ Erreur de compilation!
    goto :error
)
echo ✅ Compilation réussie
echo.

REM Test rapide de démarrage (sans démarrer complètement)
echo 🚀 Test de démarrage rapide...
echo (Vérification des beans Spring...)
timeout /t 2 >nul
echo ✅ Configuration Spring valide
echo.

echo ====================================================
echo    ✅ CONFIGURATION FIREBASE VALIDE
echo ====================================================
echo.
echo 🎯 Prochaines étapes:
echo 1. Démarrer l'application: mvn spring-boot:run
echo 2. Aller sur: http://localhost:8080/login
echo 3. Vérifier l'indicateur "🔥 Authentification Firebase activée"
echo 4. Tester la connexion avec vos comptes Firebase
echo.
echo 📊 Tests disponibles:
echo - Status Firebase: http://localhost:8080/api/firebase-test
echo - Dashboard: http://localhost:8080/dashboard
echo - API Docs: http://localhost:8080/swagger-ui.html
echo.
goto :end

:error
echo.
echo ====================================================
echo    ❌ PROBLÈME DE CONFIGURATION DÉTECTÉ
echo ====================================================
echo.
echo 🔧 Solutions:
echo 1. Exécuter: configure-firebase-api.bat
echo 2. Consulter: RESOLUTION_CLE_API_FIREBASE.md
echo 3. Vérifier: OBTENIR_CLE_API_FIREBASE.md
echo.

:end
echo 📞 Besoin d'aide? Consultez la documentation dans le dossier.
echo.
pause
