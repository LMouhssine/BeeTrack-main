@echo off
echo Test rapide Firebase...
echo.

echo 1. Verification du fichier de configuration...
if exist "config\firebase\service-account.json" (
    echo [OK] Fichier trouve
) else (
    echo [ERREUR] Fichier manquant
    exit /b 1
)

echo.
echo 2. Verification de la configuration...
findstr "rucheconnecteeesp32" "ruche-connectee\web-app\src\main\resources\application.properties" >nul
if %errorlevel% equ 0 (
    echo [OK] Configuration correcte
) else (
    echo [ERREUR] Configuration incorrecte
    exit /b 1
)

echo.
echo 3. Test de l'application...
echo Demarrage de l'application...
echo Attendez 30 secondes puis ouvrez http://localhost:8080
echo.
echo Pour arreter: Ctrl+C
echo.

cd ruche-connectee\web-app
mvn spring-boot:run 