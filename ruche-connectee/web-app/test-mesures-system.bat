@echo off
echo ===============================================
echo Test du systeme de mesures BeeTrack
echo ===============================================
echo.

set BASE_URL=http://localhost:8080
set RUCHE_ID=887D681C0610

echo 1. Test du health check...
curl -s %BASE_URL%/api/mobile/health
echo.
echo.

echo 2. Test de la derniere mesure (mobile API)...
curl -s -H "X-Apiculteur-ID: test-user" "%BASE_URL%/api/mobile/ruches/%RUCHE_ID%/derniere-mesure"
echo.
echo.

echo 3. Test de la derniere mesure (API complete)...
curl -s "%BASE_URL%/api/mesures/ruche/%RUCHE_ID%/derniere"
echo.
echo.

echo 4. Test des mesures recentes (24h)...
curl -s "%BASE_URL%/api/mesures/ruche/%RUCHE_ID%/recentes?heures=24"
echo.
echo.

echo 5. Test des statistiques (7 jours)...
curl -s "%BASE_URL%/api/mesures/ruche/%RUCHE_ID%/statistiques?jours=7"
echo.
echo.

echo 6. Test endpoint de test...
curl -s "%BASE_URL%/api/mesures/test/derniere-mesure/%RUCHE_ID%"
echo.
echo.

echo 7. Test d'ajout d'une nouvelle mesure...
curl -s -X POST "%BASE_URL%/api/mesures/ruche/%RUCHE_ID%" ^
  -H "Content-Type: application/json" ^
  -d "{\"temperature\": 25.5, \"humidity\": 65.0, \"couvercleOuvert\": false, \"batterie\": 85}"
echo.
echo.

echo ===============================================
echo Tests termines
echo ===============================================
pause
