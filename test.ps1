# test.ps1 - Script de verification de l'environnement WordPress Docker

Write-Host ""
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host "   Verification de l'environnement WordPress Docker" -ForegroundColor Cyan
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host ""

$TestsTotal = 0
$TestsOK = 0
$TestsFail = 0

# Fonction pour afficher un test reussi
function Test-OK {
    param([string]$Message)
    Write-Host "  OK  " -ForegroundColor Green -NoNewline
    Write-Host $Message
    $script:TestsOK++
    $script:TestsTotal++
}

# Fonction pour afficher un test echoue
function Test-Fail {
    param([string]$Message)
    Write-Host "  KO  " -ForegroundColor Red -NoNewline
    Write-Host $Message
    $script:TestsFail++
    $script:TestsTotal++
}

# Fonction pour afficher un avertissement
function Test-Warning {
    param([string]$Message)
    Write-Host "  !!  " -ForegroundColor Yellow -NoNewline
    Write-Host $Message
}

# Fonction pour afficher une section
function Show-Section {
    param([string]$Title)
    Write-Host ""
    Write-Host "----------------------------------------------------------------" -ForegroundColor Cyan
    Write-Host "  $Title" -ForegroundColor White
    Write-Host "----------------------------------------------------------------" -ForegroundColor Cyan
}

# 1. Verification des prerequis systeme
Show-Section "1. Prerequis systeme"

# Verifier Docker
$dockerVersion = docker --version 2>$null
if ($dockerVersion) {
    Test-OK "Docker installe: $dockerVersion"
} else {
    Test-Fail "Docker n'est pas installe ou n'est pas dans le PATH"
}

# Verifier Docker Compose
$composeVersion = docker-compose --version 2>$null
if ($composeVersion) {
    Test-OK "Docker Compose installe: $composeVersion"
} else {
    Test-Fail "Docker Compose n'est pas installe ou n'est pas dans le PATH"
}

# Verifier que Docker Desktop est lance
$dockerInfo = docker info 2>$null
if ($dockerInfo) {
    Test-OK "Docker Desktop est lance et accessible"
} else {
    Test-Fail "Docker Desktop n'est pas lance ou ne repond pas"
}

# 2. Verification de la structure du projet
Show-Section "2. Structure du projet"

$requiredFiles = @(
    "docker-compose.yml",
    "backup.ps1",
    "restore.ps1",
    "test.ps1",
    "README.md",
    "QUICKSTART.md"
)

foreach ($file in $requiredFiles) {
    if (Test-Path $file) {
        Test-OK "Fichier $file present"
    } else {
        Test-Fail "Fichier $file manquant"
    }
}

$requiredDirs = @("backups", "uploads", "themes")
foreach ($dir in $requiredDirs) {
    if (Test-Path $dir -PathType Container) {
        Test-OK "Dossier $dir/ present"
    } else {
        Test-Fail "Dossier $dir/ manquant"
    }
}

# 3. Verification des containers Docker
Show-Section "3. Etat des containers Docker"

$wpContainer = docker ps --filter "name=wordpress_app" --format "{{.Names}}" 2>$null
if ($wpContainer) {
    Test-OK "Container WordPress est en cours d'execution"
    
    # Verifier l'etat de sante (si disponible)
    $wpHealth = docker inspect --format='{{.State.Status}}' wordpress_app 2>$null
    if ($wpHealth -eq "running") {
        Test-OK "Container WordPress fonctionne correctement"
    }
} else {
    Test-Warning "Container WordPress n'est pas demarre (normal si 1ere installation)"
}

$dbContainer = docker ps --filter "name=wordpress_db" --format "{{.Names}}" 2>$null
if ($dbContainer) {
    Test-OK "Container MySQL est en cours d'execution"
    
    # Verifier l'etat de sante
    $dbHealth = docker inspect --format='{{.State.Health.Status}}' wordpress_db 2>$null
    if ($dbHealth -eq "healthy" -or $dbHealth -eq "") {
        Test-OK "Base de donnees MySQL en bonne sante"
    } else {
        Test-Fail "Base de donnees MySQL a un probleme: $dbHealth"
    }
} else {
    Test-Warning "Container MySQL n'est pas demarre (normal si 1ere installation)"
}

# 4. Verification de l'acces web
Show-Section "4. Accessibilite web"

if ($wpContainer) {
    Start-Sleep -Seconds 2
    
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:8080" -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
        if ($response.StatusCode -eq 200 -or $response.StatusCode -eq 302) {
            Test-OK "Site WordPress accessible sur http://localhost:8080"
        }
    } catch {
        Test-Fail "Site WordPress non accessible sur http://localhost:8080"
        Write-Host "     Erreur: $($_.Exception.Message)" -ForegroundColor Gray
    }
} else {
    Test-Warning "Test d'accessibilite ignore (containers non demarres)"
}

# 5. Verification des outils WordPress
Show-Section "5. Outils WordPress"

if ($wpContainer) {
    $wpCliVersion = docker exec wordpress_app wp --version --allow-root 2>$null
    if ($wpCliVersion) {
        Test-OK "WP-CLI installe dans le container: $wpCliVersion"
    } else {
        Test-Warning "WP-CLI non installe (les scripts backup/restore ne fonctionneront pas completement)"
        Write-Host "     Pour installer: docker exec -it wordpress_app bash" -ForegroundColor Gray
        Write-Host "     Puis: curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && chmod +x wp-cli.phar && mv wp-cli.phar /usr/local/bin/wp" -ForegroundColor Gray
    }
} else {
    Test-Warning "Test WP-CLI ignore (containers non demarres)"
}

# 6. Verification de Git
Show-Section "6. Configuration Git"

if (Test-Path ".git" -PathType Container) {
    Test-OK "Repository Git initialise"
    
    $gitRemote = git remote get-url origin 2>$null
    if ($gitRemote) {
        Test-OK "Remote Git configure: $gitRemote"
    } else {
        Test-Warning "Remote Git non configure"
        Write-Host "     Configurez avec: git remote add origin <URL>" -ForegroundColor Gray
    }
    
    $gitBranch = git branch --show-current 2>$null
    if ($gitBranch) {
        Test-OK "Branche Git active: $gitBranch"
    }
} else {
    Test-Warning "Git non initialise"
    Write-Host "     Initialisez avec: git init" -ForegroundColor Gray
}

# 7. Verification des sauvegardes
Show-Section "7. Sauvegardes"

$backupFiles = Get-ChildItem -Path "backups" -Filter "*.sql" -ErrorAction SilentlyContinue
if ($backupFiles) {
    $backupCount = $backupFiles.Count
    Test-OK "$backupCount sauvegarde(s) SQL trouvee(s)"
    $latestBackup = $backupFiles | Sort-Object LastWriteTime -Descending | Select-Object -First 1
    Write-Host "     Derniere sauvegarde: $($latestBackup.Name) - $($latestBackup.LastWriteTime)" -ForegroundColor Gray
} else {
    Test-Warning "Aucune sauvegarde SQL trouvee"
    Write-Host "     Creez une sauvegarde avec: .\backup.ps1" -ForegroundColor Gray
}

# Resultats finaux
Show-Section "Resultats"

Write-Host ""
Write-Host "  Tests reussis: $TestsOK / $TestsTotal" -ForegroundColor Green
Write-Host "  Tests echoues: $TestsFail / $TestsTotal" -ForegroundColor $(if ($TestsFail -gt 0) { "Red" } else { "Gray" })
Write-Host ""

if ($TestsFail -eq 0) {
    Write-Host "================================================================" -ForegroundColor Green
    Write-Host "  Tous les tests sont passes! Votre environnement est pret" -ForegroundColor Green
    Write-Host "================================================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Prochaines etapes:" -ForegroundColor Cyan
    if (-not $wpContainer) {
        Write-Host "  1. Demarrer WordPress: docker-compose up -d" -ForegroundColor White
        Write-Host "  2. Attendre 60 secondes" -ForegroundColor White
        Write-Host "  3. Acceder a: http://localhost:8080" -ForegroundColor White
    } else {
        Write-Host "  1. Configurer WordPress selon vos besoins" -ForegroundColor White
        Write-Host "  2. Sauvegarder: .\backup.ps1" -ForegroundColor White
        Write-Host "  3. Versionner: git add . && git commit && git push" -ForegroundColor White
    }
    Write-Host ""
    exit 0
} else {
    Write-Host "================================================================" -ForegroundColor Red
    Write-Host "  Certains tests ont echoue" -ForegroundColor Red
    Write-Host "================================================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "Consultez les erreurs ci-dessus et corrigez-les avant de continuer." -ForegroundColor Yellow
    Write-Host "Pour plus d'aide, consultez README.md ou QUICKSTART.md" -ForegroundColor Yellow
    Write-Host ""
    exit 1
}