@echo off
echo ===============================================
echo Demarrage BeeTrack avec donnees de test
echo ===============================================
echo.

echo 1. Compilation du projet...
call mvn clean compile -q

echo.
echo 2. Demarrage de l'application...
echo L'application sera disponible a l'adresse : http://localhost:8080
echo.
echo Pages disponibles :
echo - Dashboard : http://localhost:8080/dashboard
echo - Mesures IoT : http://localhost:8080/mesures  
echo - API mesures : http://localhost:8080/api/mesures/ruche/887D681C0610/derniere
echo.
echo Une fois demarree, vous pouvez :
echo 1. Creer des donnees de test en appelant :
echo    POST http://localhost:8080/dev/create-test-data/887D681C0610?nombreJours=3&mesuresParJour=6
echo.
echo 2. Tester l'API avec :
echo    GET http://localhost:8080/api/mesures/ruche/887D681C0610/derniere
echo.

echo Demarrage en cours...
echo.
call mvn spring-boot:run
