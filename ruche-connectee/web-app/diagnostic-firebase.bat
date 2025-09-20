@echo off
chcp 65001 >nul
echo.
echo ====================================================
echo    🧪 Diagnostic Firebase en temps réel - BeeTrack
echo ====================================================
echo.

cd /d "%~dp0"

echo 🔍 Test 1: Vérification de l'application...
curl -s http://localhost:8080/api/firebase-test >nul 2>&1
if errorlevel 1 (
    echo ❌ Application non accessible sur http://localhost:8080
    echo    L'application est-elle démarrée?
    echo    Démarrez avec: mvn spring-boot:run
    goto :end
)
echo ✅ Application accessible

echo.
echo 🔍 Test 2: Statut Firebase...
curl -s http://localhost:8080/api/firebase-test > firebase_status.json
type firebase_status.json
del firebase_status.json >nul 2>&1

echo.
echo.
echo 🔍 Test 3: Page de connexion...
curl -s http://localhost:8080/login | findstr "Authentification Firebase" >nul 2>&1
if errorlevel 1 (
    echo ⚠️ Indicateur Firebase non trouvé sur la page de connexion
) else (
    echo ✅ Page de connexion avec Firebase activée
)

echo.
echo 🔍 Test 4: Variables d'environnement...
if defined FIREBASE_API_KEY (
    echo ✅ FIREBASE_API_KEY définie: %FIREBASE_API_KEY:~0,20%...
) else (
    echo ⚠️ FIREBASE_API_KEY non définie (utilise valeur par défaut)
)

echo.
echo 🔍 Test 5: Configuration dans application.properties...
findstr "firebase.api-key" src\main\resources\application.properties

echo.
echo ====================================================
echo    🎯 INSTRUCTIONS DE TEST
echo ====================================================
echo.
echo 1. 🌐 Ouvrez votre navigateur en mode privé (Ctrl+Shift+N)
echo 2. 🔗 Allez sur: http://localhost:8080/login
echo 3. 👀 Vérifiez que "🔥 Authentification Firebase activée" s'affiche
echo 4. 🧪 Testez avec un compte Firebase valide
echo.
echo Si vous voyez encore "API key not valid":
echo - Précisez QUAND exactement le message apparaît
echo - Ouvrez F12 ^> Console pour voir les erreurs JavaScript
echo - Vérifiez si c'est dans les logs serveur ou côté navigateur
echo.

:end
echo 📞 Résultats? Dites-moi ce que vous voyez maintenant!
echo.
pause
