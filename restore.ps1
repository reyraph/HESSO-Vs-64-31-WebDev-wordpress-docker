# restore.ps1 - Script de restauration WordPress
# Restaure une sauvegarde WordPress precedemment creee

param(
    [string]$BackupFile = ""
)

$BackupDir = "backups"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Restauration WordPress" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Verifier que le dossier de backup existe
if (-not (Test-Path $BackupDir)) {
    Write-Host "ERREUR: Le dossier $BackupDir n'existe pas" -ForegroundColor Red
    exit 1
}

# Verifier que les containers sont en cours d'execution
$wpContainer = docker ps --filter "name=wordpress_app" --format "{{.Names}}"
$dbContainer = docker ps --filter "name=wordpress_db" --format "{{.Names}}"

if (-not $wpContainer) {
    Write-Host "ERREUR: Le container WordPress n'est pas en cours d'execution" -ForegroundColor Red
    Write-Host "Lancez d'abord: docker-compose up -d" -ForegroundColor Yellow
    exit 1
}

if (-not $dbContainer) {
    Write-Host "ERREUR: Le container MySQL n'est pas en cours d'execution" -ForegroundColor Red
    Write-Host "Lancez d'abord: docker-compose up -d" -ForegroundColor Yellow
    exit 1
}

# Lister les sauvegardes disponibles
Write-Host "Sauvegardes disponibles:" -ForegroundColor Green
Write-Host ""

$sqlFiles = Get-ChildItem -Path $BackupDir -Filter "*.sql" | Sort-Object LastWriteTime -Descending

if ($sqlFiles.Count -eq 0) {
    Write-Host "Aucune sauvegarde SQL trouvee dans $BackupDir" -ForegroundColor Red
    exit 1
}

$index = 1
$fileList = @()
foreach ($file in $sqlFiles) {
    $size = [math]::Round($file.Length / 1KB, 2)
    Write-Host "  [$index] $($file.Name) - $size KB - $($file.LastWriteTime)" -ForegroundColor White
    $fileList += $file
    $index++
}

Write-Host ""

# Choisir la sauvegarde
if ($BackupFile -eq "") {
    Write-Host "Entrez le numero de la sauvegarde a restaurer (ou appuyez sur Entree pour la plus recente):" -ForegroundColor Yellow
    $choice = Read-Host

    if ($choice -eq "") {
        $selectedFile = $fileList[0]
        Write-Host "Utilisation de la sauvegarde la plus recente: $($selectedFile.Name)" -ForegroundColor Cyan
    }
    elseif ($choice -match '^\d+$' -and [int]$choice -ge 1 -and [int]$choice -le $fileList.Count) {
        $selectedFile = $fileList[[int]$choice - 1]
        Write-Host "Sauvegarde selectionnee: $($selectedFile.Name)" -ForegroundColor Cyan
    }
    else {
        Write-Host "Choix invalide" -ForegroundColor Red
        exit 1
    }
}
else {
    $selectedFile = Get-Item "$BackupDir\$BackupFile" -ErrorAction SilentlyContinue
    if (-not $selectedFile) {
        Write-Host "ERREUR: Le fichier $BackupFile n'existe pas dans $BackupDir" -ForegroundColor Red
        exit 1
    }
}

# Confirmation
Write-Host ""
Write-Host "ATTENTION: Cette operation va ecraser la configuration actuelle de WordPress" -ForegroundColor Red
Write-Host "Voulez-vous continuer? (O/N)" -ForegroundColor Yellow
$confirm = Read-Host

if ($confirm -ne "O" -and $confirm -ne "o") {
    Write-Host "Restauration annulee" -ForegroundColor Yellow
    exit 0
}

Write-Host ""
Write-Host "Restauration en cours..." -ForegroundColor Cyan
Write-Host ""

# Restauration de la base de donnees
Write-Host "Restauration de la base de donnees..." -ForegroundColor Cyan

# Copier le fichier SQL dans un emplacement temporaire accessible par Docker
$tempSqlPath = "$BackupDir\temp_restore.sql"
Copy-Item -Path $selectedFile.FullName -Destination $tempSqlPath -Force

# Importer la base de donnees
$restoreCommand = "docker exec -i wordpress_db mysql -u wordpress_user -pwordpress_pass_2024 wordpress_db"
Get-Content $tempSqlPath | & docker exec -i wordpress_db mysql -u wordpress_user -pwordpress_pass_2024 wordpress_db

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERREUR lors de la restauration de la base de donnees" -ForegroundColor Red
    Remove-Item $tempSqlPath -Force -ErrorAction SilentlyContinue
    exit 1
}

# Nettoyer le fichier temporaire
Remove-Item $tempSqlPath -Force -ErrorAction SilentlyContinue

Write-Host "Base de donnees restauree avec succes" -ForegroundColor Green

# Nettoyer le cache WordPress (si WP-CLI est installe)
Write-Host "Nettoyage du cache WordPress..." -ForegroundColor Cyan
docker exec wordpress_app wp cache flush --allow-root --path=/var/www/html 2>$null
docker exec wordpress_app wp rewrite flush --allow-root --path=/var/www/html 2>$null

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  Restauration terminee avec succes!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Acces a WordPress: http://localhost:8080" -ForegroundColor Cyan
Write-Host ""
Write-Host "En cas de probleme:" -ForegroundColor Yellow
Write-Host "  - Redemarrez les containers: docker-compose restart" -ForegroundColor White
Write-Host "  - Verifiez les logs: docker-compose logs -f" -ForegroundColor White
Write-Host ""