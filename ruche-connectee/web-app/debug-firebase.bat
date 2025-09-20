@echo off
chcp 65001 >nul
echo.
echo ==========================================
echo       🐛 Debug Firebase - BeeTrack
echo ==========================================
echo.

cd /d "%~dp0"

echo 🔍 Diagnostic détaillé...
echo.

echo 1️⃣ Configuration dans application.properties:
echo -----------------------------------------------
findstr "firebase" src\main\resources\application.properties
echo.

echo 2️⃣ Test de compilation:
echo ----------------------
mvn compile -q
if errorlevel 1 (
    echo ❌ Erreur de compilation - Vérifiez les logs Maven
    pause
    exit /b 1
)
echo ✅ Compilation OK

echo.
echo 3️⃣ Recherche des erreurs dans les logs:
echo ----------------------------------------
if exist output.log (
    echo Recherche "API key not valid" dans output.log:
    findstr /i "api.*key.*not.*valid" output.log
    if errorlevel 1 (
        echo ✅ Aucune erreur API key trouvée dans output.log
    )
    echo.
    echo Dernières lignes de output.log:
    tail -n 10 output.log 2>nul || (
        echo Les 10 dernières lignes de output.log:
        for /f "tokens=*" %%a in ('type output.log') do set "lastline=%%a"
        echo !lastline!
    )
)

echo.
echo 4️⃣ Vérification du service FirebaseAuthRestService:
echo --------------------------------------------------
findstr /n "ConditionalOnProperty\|Value.*firebase.api-key" src\main\java\com\rucheconnectee\service\FirebaseAuthRestService.java

echo.
echo ==========================================
echo      🎯 SOLUTIONS RECOMMANDÉES
echo ==========================================
echo.
echo Si vous voyez encore "API key not valid":
echo.
echo 1. 🔄 Exécutez: ./force-restart.bat
echo 2. 🌐 Allez sur: http://localhost:8080/login (mode privé)
echo 3. 🔍 Ouvrez F12 ^> Console pour voir les erreurs JS
echo 4. 📝 Dites-moi EXACTEMENT où/quand l'erreur apparaît
echo.
pause
