@echo off
echo ================================================================
echo   BeeTrack - Test de l'Application Web
echo ================================================================
echo.

echo [1/3] Navigation vers le répertoire de l'application...
cd ruche-connectee\web-app
if %errorlevel% neq 0 (
    echo ERREUR: Impossible de naviguer vers ruche-connectee\web-app
    pause
    exit /b 1
)

echo [2/3] Compilation de l'application...
mvn clean compile
if %errorlevel% neq 0 (
    echo ERREUR: La compilation a échoué
    pause
    exit /b 1
)

echo [3/3] Démarrage de l'application Spring Boot...
echo.
echo ================================================================
echo   L'application démarre...
echo   Accédez à: http://localhost:8080
echo   
echo   Identifiants de test:
echo   - admin@beetrackdemo.com / admin123
echo   - apiculteur@beetrackdemo.com / demo123
echo   - jean.dupont@email.com / Azerty123
echo.
echo   Appuyez sur Ctrl+C pour arrêter l'application
echo ================================================================
echo.

mvn spring-boot:run 