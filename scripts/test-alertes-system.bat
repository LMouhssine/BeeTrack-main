@echo off
echo ========================================
echo Test du Systeme d'Alertes BeeTrack
echo ========================================
echo.

echo 1. Test de l'API d'alertes...
curl -s http://localhost:8080/api/alertes/statut
if %errorlevel% neq 0 (
    echo [ERREUR] API d'alertes non accessible
    exit /b 1
)
echo.
echo ✅ API d'alertes accessible

echo 2. Test du statut de surveillance...
curl -s http://localhost:8080/api/alertes/statut | findstr "surveillanceActive"
if %errorlevel% neq 0 (
    echo [ATTENTION] Impossible de récupérer le statut de surveillance
) else (
    echo ✅ Statut de surveillance récupéré
)
echo.

echo 3. Test des inhibitions actives...
curl -s http://localhost:8080/api/alertes/inhibition/actives
if %errorlevel% neq 0 (
    echo [ATTENTION] Impossible de récupérer les inhibitions
) else (
    echo ✅ Inhibitions récupérées
)
echo.

echo 4. Test d'envoi d'alerte (nécessite authentification)...
echo [INFO] Ce test nécessite d'être connecté
echo Pour tester manuellement:
echo curl -X POST http://localhost:8080/api/alertes/test ^
echo   -H "Content-Type: application/json" ^
echo   -d "{\"rucheId\": \"ruche_001\"}"
echo.

echo 5. Test des inhibitions (nécessite authentification)...
echo [INFO] Ce test nécessite d'être connecté
echo Pour tester manuellement:
echo curl -X POST http://localhost:8080/api/inhibitions/ruche_001/activer ^
echo   -H "Content-Type: application/json" ^
echo   -d "{\"dureeHeures\": 2}"
echo.

echo ========================================
echo Tests terminés
echo ========================================
echo.
echo Pour tester complètement le système:
echo 1. Connectez-vous à l'application web
echo 2. Allez sur http://localhost:8080/alertes
echo 3. Testez les fonctionnalités d'alerte
echo.
echo Pour vérifier les logs d'alerte:
echo - Surveillez la console de l'application
echo - Vérifiez les emails envoyés
echo - Consultez les logs Firebase 