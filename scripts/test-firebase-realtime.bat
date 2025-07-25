@echo off
echo ========================================
echo Test Firebase Realtime Database
echo ========================================

echo.
echo 1. Test de l'API Firebase...
curl -s http://localhost:8080/api/firebase-test/health
if %errorlevel% neq 0 (
    echo [ERREUR] API non accessible
    exit /b 1
)

echo.
echo 2. Test des mesures...
curl -s http://localhost:8080/api/firebase-test/mesures
if %errorlevel% neq 0 (
    echo [ERREUR] Mesures non accessibles
    exit /b 1
)

echo.
echo 3. Test des ruches...
curl -s http://localhost:8080/api/firebase-test/ruches
if %errorlevel% neq 0 (
    echo [ERREUR] Ruches non accessibles
    exit /b 1
)

echo.
echo 4. Test des ruchers...
curl -s http://localhost:8080/api/firebase-test/ruchers
if %errorlevel% neq 0 (
    echo [ERREUR] Ruchers non accessibles
    exit /b 1
)

echo.
echo 5. Test complet...
curl -s http://localhost:8080/api/firebase-test/complete
if %errorlevel% neq 0 (
    echo [ERREUR] Test complet échoué
    exit /b 1
)

echo.
echo ========================================
echo Tests termines avec succes !
echo ======================================== 