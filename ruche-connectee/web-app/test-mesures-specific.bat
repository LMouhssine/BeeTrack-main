@echo off
echo ===============================================
echo Test specifique du systeme de mesures
echo Structure: ruche/887D681C0610/historique
echo ===============================================
echo.

set BASE_URL=http://localhost:8080
set RUCHE_ID=887D681C0610

echo 1. Demarrage du serveur de test...
echo Demarrez le serveur avec: mvn spring-boot:run
echo Puis appuyez sur une touche pour continuer les tests...
pause
echo.

echo 2. Creation de donnees de test pour la ruche %RUCHE_ID%...
curl -s -X POST "%BASE_URL%/dev/create-test-data/%RUCHE_ID%?nombreJours=3&mesuresParJour=6"
echo.
echo.

echo 3. Test de la structure Firebase...
curl -s "%BASE_URL%/dev/test-firebase-structure/%RUCHE_ID%"
echo.
echo.

echo 4. Ajout d'une mesure manuelle avec les valeurs de votre exemple...
curl -s -X POST "%BASE_URL%/dev/add-mesure/%RUCHE_ID%" ^
  -H "Content-Type: application/json" ^
  -d "{\"temperature\": 28.8, \"humidity\": 56.6, \"couvercleOuvert\": true, \"batterie\": 90}"
echo.
echo.

echo 5. Test de la derniere mesure...
curl -s "%BASE_URL%/api/mesures/ruche/%RUCHE_ID%/derniere"
echo.
echo.

echo 6. Test des mesures recentes (6 heures)...
curl -s "%BASE_URL%/api/mesures/ruche/%RUCHE_ID%/recentes?heures=6"
echo.
echo.

echo 7. Test des statistiques...
curl -s "%BASE_URL%/api/mesures/ruche/%RUCHE_ID%/statistiques?jours=3"
echo.
echo.

echo 8. Test API mobile (selon la doc)...
curl -s -H "X-Apiculteur-ID: test-user" "%BASE_URL%/api/mobile/ruches/%RUCHE_ID%/derniere-mesure"
echo.
echo.

echo ===============================================
echo Tests termines pour la ruche %RUCHE_ID%
echo ===============================================
pause
