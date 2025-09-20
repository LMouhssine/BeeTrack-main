@echo off
echo ===============================================
echo Demarrage BeeTrack - Mode Debug pour Mesures
echo ===============================================
echo.

echo 1. Compilation du projet...
call mvn clean compile -q

if %ERRORLEVEL% neq 0 (
    echo ERREUR: Echec de la compilation
    pause
    exit /b 1
)

echo 2. Demarrage de l'application...
echo.
echo Application disponible sur :
echo - Page de test simple : http://localhost:8080/test-page
echo - Test mesures mockees : http://localhost:8080/mesures-test
echo - Mesures completes : http://localhost:8080/mesures
echo.
echo Solutions pour ERR_INCOMPLETE_CHUNKED_ENCODING :
echo 1. Si la page se charge partiellement, utilisez /mesures-test
echo 2. Si Firebase pose probleme, la page affichera des donnees par defaut
echo 3. Consultez les logs de la console ci-dessous
echo.

echo Demarrage en cours...
echo.

REM Utiliser spring-boot:run avec plus de mémoire et debugging
set MAVEN_OPTS=-Xmx1024m -Xms512m -Dspring.devtools.restart.enabled=false

call mvn spring-boot:run -Dspring-boot.run.profiles=local
