@echo off
echo ========================================
echo Fix pour la boucle de redirection (ERR_TOO_MANY_REDIRECTS)
echo ========================================

echo 1. Nettoyage des logs
cd /d "%~dp0\..\ruche-connectee\web-app"
if exist output.log (
    copy output.log output_backup.log
    echo. > output.log
)

echo 2. Arrêt de l'application (si en cours)
taskkill /f /im java.exe /t >nul 2>&1

echo 3. Nettoyage du cache Maven
mvn clean >nul 2>&1

echo 4. Compilation avec les corrections
echo    - Template layout.html: protection null pour #authentication
echo    - Template dashboard.html: protection null pour #authentication
echo    - SecurityConfig.java: amélioration de la gestion des sessions
mvn compile -q

if %ERRORLEVEL% neq 0 (
    echo ERREUR: Compilation échouée
    pause
    exit /b 1
)

echo 5. Démarrage de l'application
echo    Port: 8080
echo    URL: http://localhost:8080/login
echo.
echo CREDENTIALS DE TEST:
echo Email: jean.dupont@email.com
echo Mot de passe: Azerty123
echo.
echo Démarrage en cours...

start /b mvn spring-boot:run

echo 6. Attente du démarrage...
timeout /t 10 /nobreak >nul

echo 7. Test de l'authentification
echo Ouverture du navigateur sur la page de login...
start http://localhost:8080/login

echo.
echo ========================================
echo INSTRUCTIONS DE TEST:
echo 1. Connectez-vous avec:
echo    - Email: jean.dupont@email.com
echo    - Mot de passe: Azerty123
echo 2. Vérifiez que vous êtes redirigé vers le dashboard sans boucle
echo 3. Le nom d'utilisateur doit s'afficher correctement
echo ========================================
echo.
echo Pour voir les logs en temps réel:
echo tail -f output.log
echo.
pause 