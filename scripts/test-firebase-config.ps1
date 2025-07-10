Write-Host "========================================" -ForegroundColor Green
Write-Host "Test de la configuration Firebase" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green

Write-Host ""
Write-Host "1. Verification du fichier de configuration..." -ForegroundColor Yellow
if (Test-Path "config\firebase\service-account.json") {
    Write-Host "[OK] Fichier service-account.json trouve" -ForegroundColor Green
} else {
    Write-Host "[ERREUR] Fichier service-account.json manquant" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "2. Verification du projet ID..." -ForegroundColor Yellow
$content = Get-Content "ruche-connectee\web-app\src\main\resources\application.properties"
if ($content -match "rucheconnecteeesp32") {
    Write-Host "[OK] Projet ID configure correctement" -ForegroundColor Green
} else {
    Write-Host "[ERREUR] Projet ID non configure" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "3. Test de connexion Firebase..." -ForegroundColor Yellow
Set-Location "ruche-connectee\web-app"

# Démarrer l'application en arrière-plan
$process = Start-Process -FilePath "mvn" -ArgumentList "spring-boot:run" -PassThru -NoNewWindow

# Attendre un peu pour que l'application démarre
Start-Sleep -Seconds 15

# Vérifier si l'application fonctionne
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8080" -TimeoutSec 10 -ErrorAction Stop
    Write-Host "[OK] Application accessible sur http://localhost:8080" -ForegroundColor Green
} catch {
    Write-Host "[ATTENTION] Application non accessible sur http://localhost:8080" -ForegroundColor Yellow
    Write-Host "Vérifiez les logs pour plus de détails" -ForegroundColor Yellow
}

# Arrêter l'application
if ($process -and -not $process.HasExited) {
    Stop-Process -Id $process.Id -Force
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "Test termine" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green 