@echo off
echo ========================================
echo Test Firebase Realtime Database
echo ========================================

echo.
echo 1. Test de connexion a la base de donnees...
curl -X GET "https://rucheconnecteeesp32-default-rtdb.europe-west1.firebasedatabase.app/.json" -H "Content-Type: application/json"

echo.
echo 2. Test d'ecriture d'une donnee de test...
curl -X PUT "https://rucheconnecteeesp32-default-rtdb.europe-west1.firebasedatabase.app/test.json" -H "Content-Type: application/json" -d "{\"message\":\"Test Realtime Database\",\"timestamp\":%time%}"

echo.
echo 3. Test de lecture de la donnee de test...
curl -X GET "https://rucheconnecteeesp32-default-rtdb.europe-west1.firebasedatabase.app/test.json" -H "Content-Type: application/json"

echo.
echo 4. Nettoyage - suppression de la donnee de test...
curl -X DELETE "https://rucheconnecteeesp32-default-rtdb.europe-west1.firebasedatabase.app/test.json"

echo.
echo ========================================
echo Test termine
echo ========================================
pause 