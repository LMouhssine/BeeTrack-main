@echo off
echo ========================================
echo Test de compilation BeeTrack
echo ========================================

echo.
echo 1. Nettoyage du projet...
cd ruche-connectee\web-app
call mvn clean

echo.
echo 2. Compilation du projet...
call mvn compile

echo.
echo 3. Verification des erreurs...
if %errorlevel% equ 0 (
    echo ✅ Compilation reussie !
    echo.
    echo 4. Test de demarrage...
    echo Appuyez sur Ctrl+C pour arreter l'application
    call mvn spring-boot:run
) else (
    echo ❌ Erreurs de compilation detectees
    echo.
    echo Erreurs principales a corriger :
    echo - Verifier les imports TimeoutException
    echo - Adapter les methodes Firestore vers Realtime Database
    echo - Corriger les types Map<String, Object> vs QueryDocumentSnapshot
)

echo.
echo ========================================
echo Test termine
echo ========================================
pause 