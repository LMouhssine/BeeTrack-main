@echo off
echo 🔥 Démarrage de BeeTrack avec authentification Firebase...
echo.

rem Configuration des variables d'environnement Firebase
set FIREBASE_PROJECT_ID=rucheconnecteeesp32
set FIREBASE_CREDENTIALS_PATH=firebase-service-account.json
set FIREBASE_DATABASE_URL=https://rucheconnecteeesp32-default-rtdb.europe-west1.firebasedatabase.app/
set FIREBASE_API_KEY=AIzaSyBOo8k8r1m3a6N-eGOQ1C-2KOdOEn4Hq0e8

echo ✅ Variables d'environnement Firebase configurées:
echo    - Project ID: %FIREBASE_PROJECT_ID%
echo    - API Key: ***%FIREBASE_API_KEY:~-6%
echo    - Database URL: %FIREBASE_DATABASE_URL%
echo.

echo 🚀 Démarrage de l'application Spring Boot...
echo    - URL d'accès: http://localhost:8080/firebase-login
echo    - Dashboard: http://localhost:8080/dashboard
echo.

rem Démarrer l'application
mvn spring-boot:run
