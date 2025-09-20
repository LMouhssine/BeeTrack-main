@echo off
chcp 65001 >nul
echo.
echo ==========================================
echo    🔥 BeeTrack - Démarrage avec votre clé
echo ==========================================
echo.

cd /d "%~dp0"

echo ✅ Votre clé API Firebase: AIzaSyCVuz8sO1DXUMzv... 
echo ✅ Clé testée et validée
echo ✅ Configuration mise à jour

echo.
echo 🧹 Nettoyage pour nouvelle configuration...
mvn clean -q

echo.
echo 🚀 Démarrage de BeeTrack avec votre clé Firebase...
echo.
echo ⏳ Attendez le message "Started BeeTrackApplication"
echo 🌐 Puis allez sur: http://localhost:8080/login
echo.

mvn spring-boot:run

echo.
echo 📞 Application arrêtée.
pause
