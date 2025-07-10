@echo off
echo ========================================
echo Test de la configuration Firebase
echo ========================================

echo.
echo 1. Verification du fichier de configuration...
if exist "config\firebase\service-account.json" (
    echo [OK] Fichier service-account.json trouve
) else (
    echo [ERREUR] Fichier service-account.json manquant
    exit /b 1
)

echo.
echo 2. Verification du projet ID...
findstr "rucheconnecteeesp32" "ruche-connectee\web-app\src\main\resources\application.properties" >nul
if %errorlevel% equ 0 (
    echo [OK] Projet ID configure correctement
) else (
    echo [ERREUR] Projet ID non configure
    exit /b 1
)

echo.
echo 3. Test de connexion Firebase...
cd ruche-connectee\web-app
mvn spring-boot:run -Dspring-boot.run.arguments="--firebase.project-id=rucheconnecteeesp32" > firebase-test.log 2>&1
timeout /t 10 /nobreak >nul

echo.
echo 4. Verification des logs...
findstr "Firebase initialise avec succes" firebase-test.log >nul
if %errorlevel% equ 0 (
    echo [OK] Firebase connecte avec succes
) else (
    echo [ERREUR] Probleme de connexion Firebase
    echo Voir les logs dans firebase-test.log
)

echo.
echo ========================================
echo Test termine
echo ======================================== 