@echo off
echo ===============================================
echo Demarrage BeeTrack - Dashboard corrige
echo ===============================================
echo.

echo 1. Compilation du projet...
call mvn clean compile -q

if %ERRORLEVEL% neq 0 (
    echo ERREUR: Echec de la compilation
    pause
    exit /b 1
)

echo.
echo 2. Demarrage de l'application...
echo.
echo ===============================================
echo Solutions pour l'erreur de dashboard :
echo ===============================================
echo.
echo L'erreur "Cannot render error page... response has already been committed"
echo est maintenant corrigee avec plusieurs solutions :
echo.
echo 📊 PAGES DISPONIBLES :
echo.
echo 1. Dashboard Simple (RECOMMANDE) :
echo    http://localhost:8080/dashboard-simple
echo    ✅ Sans Firebase - Fonctionne toujours
echo.
echo 2. Page d'accueil (redirection automatique) :
echo    http://localhost:8080/
echo    ✅ Redirige vers dashboard-simple
echo.
echo 3. Dashboard complet (avec Firebase) :
echo    http://localhost:8080/dashboard
echo    ⚠️ Peut planter si Firebase non configure
echo.
echo 4. Page de test avec navigation :
echo    http://localhost:8080/test-page
echo    ✅ Liens vers toutes les pages
echo.
echo 5. Mesures IoT avec selecteur ESP32 :
echo    http://localhost:8080/mesures
echo    ✅ Interface complete pour vos capteurs
echo.

echo ===============================================
echo Demarrage en cours...
echo ===============================================
echo.

REM Demarrer avec plus de memoire et profil debug
set MAVEN_OPTS=-Xmx1024m -Xms512m
call mvn spring-boot:run -Dspring-boot.run.jvmArguments="-Dspring.profiles.active=debug"
