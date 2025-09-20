@echo off
echo ===============================================
echo Test du selecteur ESP32 - BeeTrack
echo ===============================================
echo.

set BASE_URL=http://localhost:8080

echo 1. Verification que l'application est demarree...
echo Assurez-vous que l'application Spring Boot tourne sur le port 8080
echo.
timeout /t 3 /nobreak > nul

echo 2. Creation de donnees de test pour votre ESP32 principal...
curl -s -X POST "%BASE_URL%/dev/create-test-data/887D681C0610?nombreJours=2&mesuresParJour=6"
echo.
echo.

echo 3. Creation de donnees de test pour ESP32 de test...
curl -s -X POST "%BASE_URL%/dev/create-test-data/R001?nombreJours=1&mesuresParJour=4"
echo.
echo.

echo 4. Test API pour ESP32 principal...
curl -s "%BASE_URL%/api/mesures/ruche/887D681C0610/derniere"
echo.
echo.

echo 5. Test API pour ESP32 de test...
curl -s "%BASE_URL%/api/mesures/ruche/R001/derniere"
echo.
echo.

echo ===============================================
echo Tests des URLs avec selecteur ESP32
echo ===============================================

echo.
echo Maintenant testez dans votre navigateur :
echo.
echo 1. Page complete avec tous les ESP32 :
echo    %BASE_URL%/mesures
echo.
echo 2. Page filtree pour votre ESP32 principal :
echo    %BASE_URL%/mesures?esp=887D681C0610
echo.
echo 3. Page filtree pour ESP32 de test :
echo    %BASE_URL%/mesures?esp=R001
echo.
echo 4. Page de details pour votre ESP32 :
echo    %BASE_URL%/mesures/ruche/887D681C0610
echo.

echo ===============================================
echo Fonctionnalites du selecteur ESP32
echo ===============================================

echo.
echo Dans l'interface web, vous pouvez :
echo - Utiliser le menu deroulant en haut a droite pour changer d'ESP32
echo - Cliquer sur les cartes ESP32 pour les selectionner
echo - Voir les mesures en temps reel de l'ESP32 selectionne
echo - Creer des donnees de test avec le bouton "Donnees test"
echo - Voir les details d'un ESP32 avec le bouton "Details"
echo.

echo Votre ESP32 principal (887D681C0610) est pre-selectionne par defaut.
echo.
pause
