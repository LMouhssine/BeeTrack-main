@echo off
echo ========================================
echo Demarrage BeeTrack avec Realtime Database
echo ========================================

echo.
echo 1. Verification de la configuration...
if not exist "ruche-connectee\web-app\src\main\resources\firebase-service-account.json" (
    echo ERREUR: Fichier firebase-service-account.json manquant
    echo Veuillez placer le fichier dans ruche-connectee\web-app\src\main\resources\
    pause
    exit /b 1
)

echo Configuration OK

echo.
echo 2. Test de connexion Realtime Database...
curl -s -X GET "https://rucheconnecteeesp32-default-rtdb.europe-west1.firebasedatabase.app/.json" > nul
if %errorlevel% neq 0 (
    echo ATTENTION: Impossible de se connecter a Realtime Database
    echo Verifiez que Realtime Database est active dans la console Firebase
) else (
    echo Connexion Realtime Database OK
)

echo.
echo 3. Compilation et demarrage de l'application...
cd ruche-connectee\web-app

echo Nettoyage...
call mvn clean

echo Compilation...
call mvn compile

echo Demarrage...
call mvn spring-boot:run

echo.
echo ========================================
echo Application demarree
echo URL: http://localhost:8080
echo ========================================
pause 