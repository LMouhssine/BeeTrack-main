@echo off
echo ========================================
echo   RESOLUTION IMMEDIATE REDIRECTS
echo ========================================
echo.

echo PROBLEME: ERR_TOO_MANY_REDIRECTS
echo.

echo SOLUTION IMMEDIATE:
echo.

echo 1. SUPPRIMER LES COOKIES:
echo    Chrome/Edge/Firefox: Ctrl + Shift + Delete
echo    Puis "Effacer les donnees"
echo.

echo 2. OU utiliser la NAVIGATION PRIVEE:
echo    Chrome: Ctrl + Shift + N
echo    Firefox: Ctrl + Shift + P
echo    Edge: Ctrl + Shift + P
echo.

echo 3. Puis aller sur: http://localhost:8080/login
echo.

echo 4. Se connecter avec:
echo    Email: admin@beetrackdemo.com
echo    Mot de passe: admin123
echo.

echo ========================================
echo   REDEMARRAGE APPLICATION (OPTIONNEL)
echo ========================================
echo.

echo Si le probleme persiste, redemarrez l'application:
echo.

echo Dans le terminal de l'application:
echo 1. Appuyez sur Ctrl + C
echo 2. Executez: scripts\start-beetrck.bat
echo.

echo OUVERTURE AUTOMATIQUE...
echo.

timeout /t 3 /nobreak >nul

echo Ouverture de la page de connexion...
start http://localhost:8080/login

echo.
echo Si la page ne s'ouvre pas:
echo 1. Supprimez vos cookies
echo 2. Utilisez la navigation privee
echo 3. Allez manuellement sur: http://localhost:8080/login
echo.

echo Appuyez sur une touche pour fermer...
pause >nul 