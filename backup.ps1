# backup.ps1 - Script de sauvegarde WordPress
$BackupDir = "backups"
$Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$BackupFile = "wordpress_config_$Timestamp"

Write-Host "=== Sauvegarde WordPress ===" -ForegroundColor Green

# Verifier que le container tourne
$container = docker ps --filter "name=wordpress_app" --format "{{.Names}}"
if (-not $container) {
    Write-Host "ERREUR: Le container WordPress n'est pas en cours d'execution" -ForegroundColor Red
    Write-Host "Lancez d'abord: docker-compose up -d" -ForegroundColor Yellow
    exit 1
}

# Creer le dossier de backup
if (-not (Test-Path $BackupDir)) {
    New-Item -ItemType Directory -Path $BackupDir | Out-Null
}

# Export de la base de donnees
Write-Host "Export de la base de donnees..." -ForegroundColor Cyan
docker exec wordpress_db mysqldump -u wordpress_user -pwordpress_pass_2024 wordpress_db | Out-File -FilePath "$BackupDir\$BackupFile.sql" -Encoding utf8

# Compresser le fichier SQL (optionnel)
# Decommentez si vous avez 7-Zip installe
# & "C:\Program Files\7-Zip\7z.exe" a "$BackupDir\$BackupFile.sql.gz" "$BackupDir\$BackupFile.sql"
# Remove-Item "$BackupDir\$BackupFile.sql"

# Export de la liste des plugins
Write-Host "Export de la liste des plugins..." -ForegroundColor Cyan
try {
    docker exec wordpress_app wp plugin list --allow-root --path=/var/www/html --format=json | Out-File -FilePath "$BackupDir\plugins_list.json" -Encoding utf8
} catch {
    Write-Host "Attention: Impossible d'exporter la liste des plugins (WP-CLI non installe?)" -ForegroundColor Yellow
    echo "[]" | Out-File -FilePath "$BackupDir\plugins_list.json" -Encoding utf8
}

# Export de la liste des themes
Write-Host "Export de la liste des themes..." -ForegroundColor Cyan
try {
    docker exec wordpress_app wp theme list --allow-root --path=/var/www/html --format=json | Out-File -FilePath "$BackupDir\themes_list.json" -Encoding utf8
} catch {
    Write-Host "Attention: Impossible d'exporter la liste des themes (WP-CLI non installe?)" -ForegroundColor Yellow
    echo "[]" | Out-File -FilePath "$BackupDir\themes_list.json" -Encoding utf8
}

# Export des options WordPress
Write-Host "Export des options WordPress..." -ForegroundColor Cyan
try {
    docker exec wordpress_app wp option get blogname --allow-root --path=/var/www/html | Out-File -FilePath "$BackupDir\wp_blogname.txt" -Encoding utf8
} catch {
    echo "Mon Site WordPress" | Out-File -FilePath "$BackupDir\wp_blogname.txt" -Encoding utf8
}

try {
    docker exec wordpress_app wp option get siteurl --allow-root --path=/var/www/html | Out-File -FilePath "$BackupDir\wp_siteurl.txt" -Encoding utf8
} catch {
    echo "http://localhost:8080" | Out-File -FilePath "$BackupDir\wp_siteurl.txt" -Encoding utf8
}

Write-Host ""
Write-Host "=== Sauvegarde terminee avec succes! ===" -ForegroundColor Green
Write-Host ""
Write-Host "Fichiers crees dans le dossier $BackupDir\" -ForegroundColor White
Write-Host "  - $BackupFile.sql (base de donnees)" -ForegroundColor Gray
Write-Host "  - plugins_list.json (liste des plugins)" -ForegroundColor Gray
Write-Host "  - themes_list.json (liste des themes)" -ForegroundColor Gray
Write-Host "  - wp_*.txt (configuration WordPress)" -ForegroundColor Gray
Write-Host ""
Write-Host "Pour versionner sur Git:" -ForegroundColor Yellow
Write-Host "  git add backups/" -ForegroundColor White
Write-Host "  git commit -m 'Sauvegarde configuration WordPress - $Timestamp'" -ForegroundColor White
Write-Host "  git push" -ForegroundColor White