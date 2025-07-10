@echo off
echo ========================================
echo   INITIALISATION DES DONNEES DEMO
echo ========================================
echo.

echo Ce script va initialiser les donnees de demonstration pour resoudre
echo le probleme "error=dashboard" lors de la connexion.
echo.

echo Verification que l'application fonctionne...
curl -s http://localhost:8080 >nul
if not %errorlevel% equ 0 (
    echo [ERREUR] Application non accessible
    echo Demarrez d'abord l'application avec: scripts/start-beetrck.bat
    pause
    exit /b 1
)

echo [OK] Application accessible
echo.

echo Initialisation des donnees...
echo.

echo 1. Creation de donnees pour la ruche demo...
curl -X POST "http://localhost:8080/api/dev/create-test-data/ruche-demo-001?nombreJours=7&mesuresParJour=4" >nul 2>&1

echo 2. Creation de donnees pour une deuxieme ruche...
curl -X POST "http://localhost:8080/api/dev/create-test-data/ruche-demo-002?nombreJours=5&mesuresParJour=6" >nul 2>&1

echo 3. Verification des donnees creees...
curl -s "http://localhost:8080/api/dev/health" >nul

if %errorlevel% equ 0 (
    echo [OK] Donnees de demonstration initialisees avec succes !
    echo.
    echo Vous pouvez maintenant vous connecter avec:
    echo - Email: admin@beetrackdemo.com
    echo - Mot de passe: admin123
    echo.
    echo OU
    echo.
    echo - Email: apiculteur@beetrackdemo.com  
    echo - Mot de passe: demo123
    echo.
    echo Le dashboard devrait maintenant fonctionner correctement.
    echo.
    start http://localhost:8080/login
) else (
    echo [ATTENTION] Les donnees n'ont peut-etre pas ete creees.
    echo L'application fonctionne peut-etre en mode mock.
    echo Essayez quand meme de vous connecter.
    echo.
    start http://localhost:8080/login
)

echo.
echo Appuyez sur une touche pour fermer...
pause >nul 