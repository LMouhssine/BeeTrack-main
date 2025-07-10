@echo off
echo.
echo ========================================
echo       DEMARRAGE BEETRCK
echo ========================================
echo.

echo Verification de l'environnement...
echo.

REM Verification du repertoire
if not exist "ruche-connectee\web-app\pom.xml" (
    echo [ERREUR] Vous devez etre dans le repertoire racine du projet BeeTrack
    echo Verifiez que vous etes dans BeeTrack-main\
    pause
    exit /b 1
)

REM Verification du fichier Firebase
if exist "ruche-connectee\web-app\src\main\resources\firebase-service-account.json" (
    echo [OK] Fichier Firebase trouve
) else (
    echo [ATTENTION] Fichier Firebase manquant - l'application fonctionnera en mode mock
)

echo.
echo Demarrage de l'application...
echo.
echo Une fois demarre:
echo - Application disponible sur: http://localhost:8080
echo - Dashboard: http://localhost:8080/dashboard
echo - Ruchers: http://localhost:8080/ruchers
echo - Ruches: http://localhost:8080/ruches
echo.
echo Pour arreter l'application: Ctrl+C
echo.

cd ruche-connectee\web-app
mvn spring-boot:run 