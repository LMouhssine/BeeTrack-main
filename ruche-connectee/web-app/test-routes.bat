@echo off
echo ===============================================
echo Test des routes BeeTrack
echo ===============================================
echo.

set BASE_URL=http://localhost:8080

echo 1. Test de la page de test simple...
curl -s "%BASE_URL%/test-page"
echo.
echo.

echo 2. Test de la route des mesures (API)...
curl -s "%BASE_URL%/api/mesures/ruche/887D681C0610/derniere"
echo.
echo.

echo 3. Test de creation de donnees...
curl -s -X POST "%BASE_URL%/dev/create-test-data/887D681C0610?nombreJours=1&mesuresParJour=3"
echo.
echo.

echo 4. Test de la route des mesures apres creation...
curl -s "%BASE_URL%/api/mesures/ruche/887D681C0610/derniere"
echo.
echo.

echo 5. Test du health check mobile...
curl -s "%BASE_URL%/api/mobile/health"
echo.
echo.

echo ===============================================
echo Tests termines
echo ===============================================

echo.
echo Maintenant testez dans votre navigateur :
echo - Page de test : %BASE_URL%/test-page
echo - Test mesures : %BASE_URL%/test-mesures-simple
echo - Mesures IoT : %BASE_URL%/mesures
echo.
pause
