@echo off
chcp 65001 >nul
echo.
echo ====================================================
echo    🔥 Configuration de la clé API Firebase - BeeTrack
echo ====================================================
echo.

echo 📋 Ce script va vous aider à configurer votre clé API Firebase.
echo.

echo 🔍 Étape 1: Vérifier la configuration actuelle...
cd /d "%~dp0"

if not exist "src\main\resources\application.properties" (
    echo ❌ Erreur: Fichier application.properties non trouvé!
    echo    Assurez-vous d'être dans le dossier ruche-connectee/web-app
    pause
    exit /b 1
)

echo ✅ Fichier application.properties trouvé
echo.

echo 🌐 Étape 2: Obtenir votre clé API Firebase
echo.
echo Pour obtenir votre clé API Firebase:
echo 1. Allez sur: https://console.firebase.google.com/
echo 2. Sélectionnez le projet "rucheconnecteeesp32"
echo 3. Cliquez sur ⚙️ Paramètres du projet
echo 4. Dans "Vos applications", trouvez votre app web
echo 5. Copiez la valeur "apiKey" (commence par AIzaSy...)
echo.

set /p "userChoice=Avez-vous votre clé API? (o/n): "
if /i "%userChoice%" neq "o" (
    echo.
    echo 📞 Besoin d'aide? Consultez le guide:
    echo OBTENIR_CLE_API_FIREBASE.md
    echo.
    pause
    exit /b 0
)

echo.
set /p "apiKey=Collez votre clé API Firebase: "

if "%apiKey%"=="" (
    echo ❌ Erreur: Clé API vide!
    pause
    exit /b 1
)

echo.
echo 🔑 Clé API fournie: %apiKey:~0,20%...
echo.

echo 💾 Étape 3: Configuration de la clé API...

REM Sauvegarder le fichier original
copy "src\main\resources\application.properties" "src\main\resources\application.properties.backup" >nul
echo ✅ Sauvegarde créée: application.properties.backup

REM Configurer la variable d'environnement
echo 🔧 Configuration de la variable d'environnement...
setx FIREBASE_API_KEY "%apiKey%" >nul
set FIREBASE_API_KEY=%apiKey%

echo ✅ Variable d'environnement FIREBASE_API_KEY configurée
echo.

echo 🚀 Étape 4: Test de la configuration...
echo.
echo 📝 Démarrage de l'application pour tester...
echo (Cela peut prendre quelques instants...)
echo.

mvn spring-boot:run -Dspring-boot.run.arguments="--logging.level.com.rucheconnectee=INFO"

echo.
echo ✅ Configuration terminée!
echo.
echo 🎯 Prochaines étapes:
echo 1. L'application devrait démarrer sans erreur de clé API
echo 2. Allez sur: http://localhost:8080/login
echo 3. Vérifiez que "🔥 Authentification Firebase activée" s'affiche
echo 4. Testez la connexion avec vos comptes Firebase
echo.
echo 📞 Besoin d'aide? Consultez:
echo - GUIDE_LOGIN_FIREBASE.md
echo - TEST_AUTHENTIFICATION.md
echo.
pause
