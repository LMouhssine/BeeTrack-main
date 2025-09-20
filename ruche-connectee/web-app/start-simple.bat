@echo off
chcp 65001 >nul
echo.
echo ==========================================
echo        🚀 BeeTrack - Démarrage Simple
echo ==========================================
echo.

REM Aller dans le bon répertoire
cd /d "%~dp0"
echo 📁 Répertoire de travail: %CD%

echo.
echo 🔧 Configuration simplifiée activée
echo ✅ Clé Firebase intégrée directement
echo ✅ Interface de connexion unique
echo ✅ Pas de variables d'environnement

echo.
echo 🧹 Nettoyage Maven...
mvn clean -q

echo.
echo 🚀 Démarrage de l'application...
echo ⏳ Attendez le message "Started BeeTrackApplication"...
echo.

mvn spring-boot:run

echo.
echo 📞 L'application s'est arrêtée.
echo 💡 Si tout fonctionne, allez sur: http://localhost:8080/login
echo.
pause
