@echo off
echo ========================================
echo Test final de l'application BeeTrack
echo ========================================

echo.
echo 1. Verification du fichier Firebase...
if exist "src\main\resources\firebase-service-account.json" (
    echo [OK] Fichier Firebase trouve
) else (
    echo [ERREUR] Fichier Firebase manquant
    exit /b 1
)

echo.
echo 2. Verification de la configuration...
findstr "rucheconnecteeesp32" "src\main\resources\application.properties" >nul
if %errorlevel% equ 0 (
    echo [OK] Configuration correcte
) else (
    echo [ERREUR] Configuration incorrecte
    exit /b 1
)

echo.
echo 3. Test de l'application...
echo Demarrage de l'application...
echo Attendez 30 secondes puis testez les URLs suivantes:
echo.
echo - Page principale: http://localhost:8080
echo - Dashboard: http://localhost:8080/dashboard
echo - Ruchers: http://localhost:8080/ruchers
echo - Ruches: http://localhost:8080/ruches
echo.
echo Pour arreter: Ctrl+C
echo.

mvn spring-boot:run 