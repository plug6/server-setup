# =========================
# CONFIG
# =========================
$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

$BASE_DIR = "C:\apps\insight"
$NGINX_DIR = "C:\nginx"
$LOG_FILE = "C:\setup-log.txt"

# =========================
# LOGGING
# =========================
Start-Transcript -Path $LOG_FILE -Append

function Refresh-Path {
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" +
                [System.Environment]::GetEnvironmentVariable("Path","User")
}

function Assert-Command($cmd) {
    if (-not (Get-Command $cmd -ErrorAction SilentlyContinue)) {
        throw "$cmd not available after install"
    }
}

function Download-And-Install($url, $outfile, $args) {
    Write-Host "Downloading $outfile ..."
    Invoke-WebRequest $url -OutFile $outfile

    Write-Host "Installing $outfile ..."
    Start-Process $outfile -ArgumentList $args -Wait -NoNewWindow
}

# =========================
# INSTALL GIT + NODE (winget)
# =========================
Write-Host "Installing Git + Node via winget..."

winget install --id Git.Git -e --accept-package-agreements --accept-source-agreements --silent
winget install --id OpenJS.NodeJS.LTS -e --accept-package-agreements --accept-source-agreements --silent

Start-Sleep 3
Refresh-Path

Assert-Command "git"
Assert-Command "node"
Assert-Command "npm"

# =========================
# INSTALL PM2
# =========================
Write-Host "Installing PM2..."
npm install -g pm2
Assert-Command "pm2"

# =========================
# INSTALL POSTGRESQL (DIRECT)
# =========================
Write-Host "Installing PostgreSQL..."

$pgInstaller = "postgresql-18.3.exe"
$pgUrl = "https://get.enterprisedb.com/postgresql/postgresql-18.3-3-windows-x64.exe"

Download-And-Install $pgUrl $pgInstaller "--mode unattended --unattendedmodeui minimal --superpassword postgres --servicename postgresql-x64-15"

Refresh-Path

if (-not (Get-Command "psql" -ErrorAction SilentlyContinue)) {
    Write-Host "WARNING: psql not found in PATH. Adding manually..."

    $pgPath = "C:\Program Files\PostgreSQL\15\bin"
    if (Test-Path $pgPath) {
        $env:Path += ";$pgPath"
    }
}

Assert-Command "psql"

# =========================
# INSTALL NGINX (ZIP METHOD)
# =========================
Write-Host "Installing Nginx..."

$nginxZip = "nginx.zip"
# https://nginx.org/en/download.html
$nginxUrl = "https://nginx.org/download/nginx-1.30.0.zip"

Invoke-WebRequest $nginxUrl -OutFile $nginxZip

Expand-Archive $nginxZip -DestinationPath "C:\" -Force

Rename-Item "C:\nginx-1.30.0" $NGINX_DIR -ErrorAction SilentlyContinue

$env:Path += ";$NGINX_DIR"

Assert-Command "nginx"

# =========================
# CREATE PROJECT STRUCTURE
# =========================
Write-Host "Creating project directories..."

New-Item -ItemType Directory -Force -Path $BASE_DIR
Set-Location $BASE_DIR

# =========================
# CLONE REPOS (EDIT THESE)
# =========================
Write-Host "Cloning repositories..."

Write-Host "Cloning Backend Repo"
git clone git@github.com:vishaltools-it/hana-insight.git backend

Write-Host "Cloning Frontend Repo"
git clone git@github.com:vishaltools-it/hana-insight-ui.git frontend

# =========================
# FINAL CHECK
# =========================
Write-Host "Verifying installations..."

git --version
node -v
npm -v
pm2 -v
psql --version
nginx -v

Write-Host "Setup completed successfully." -ForegroundColor Green

Stop-Transcript