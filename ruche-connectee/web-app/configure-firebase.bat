@echo off
echo 🔥 Configuration Firebase pour BeeTrack
echo.

echo 📋 Pour récupérer votre clé API Firebase :
echo 1. Allez sur https://console.firebase.google.com/
echo 2. Sélectionnez le projet "rucheconnecteeesp32"
echo 3. Cliquez sur ⚙️ Paramètres du projet
echo 4. Dans l'onglet "Général", descendez à "Vos applications"
echo 5. Trouvez votre app web et cliquez sur "Configuration"
echo 6. Copiez la valeur apiKey
echo.

set /p API_KEY="🔑 Collez votre clé API Firebase ici : "

if "%API_KEY%"=="" (
    echo ❌ Aucune clé API fournie !
    pause
    exit /b 1
)

echo.
echo ✅ Configuration de la clé API : %API_KEY%
echo.

rem Configurer la variable d'environnement
set FIREBASE_API_KEY=%API_KEY%

echo 🚀 Démarrage de l'application avec Firebase...
mvn spring-boot:run

pause
