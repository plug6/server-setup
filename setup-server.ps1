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

function Download-And-Install($url, $outfile, $installArgs) {

    Write-Host "Downloading $outfile ..."

    Invoke-WebRequest $url -OutFile $outfile

    if (!(Test-Path $outfile)) {
        throw "$outfile download failed"
    }

    Unblock-File ".\$outfile"

    Write-Host "Installing $outfile ..."

    $process = Start-Process ".\$outfile" `
        -ArgumentList $installArgs `
        -Wait `
        -PassThru

    Write-Host "Installer Exit Code: $($process.ExitCode)"

    if ($process.ExitCode -ne 0) {
        throw "$outfile installer failed with exit code $($process.ExitCode)"
    }
}

try {
    # =========================
    # INSTALL GIT + NODE (winget)
    # =========================
    Write-Host "Installing Git via winget..."
    winget install --id Git.Git -e --accept-package-agreements --accept-source-agreements --silent

    Write-Host "Installing Node via winget..."
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

    $pgPassword = Read-Host "Enter postgres password [default: postgres]"

    if ([string]::IsNullOrWhiteSpace($pgPassword)) {
        $pgPassword = "postgres"
    }

    $pgInstallArgs =
        "--mode unattended " +
        "--unattendedmodeui minimal " +
        "--superpassword $pgPassword " +
        "--servicename postgresql-x64-18 " +
        "--disable-components stackbuilder,pgAdmin " +
        "--create_shortcuts 0 " +
        "--enable_acledit 1"

    Download-And-Install $pgUrl $pgInstaller $pgInstallArgs

    Refresh-Path

    $pgPath = "C:\Program Files\PostgreSQL\18\bin"

    if (Test-Path $pgPath) {

        # Add to current session
        if ($env:Path -notlike "*$pgPath*") {
            $env:Path += ";$pgPath"
        }

        # Add permanently to system PATH
        $machinePath = [Environment]::GetEnvironmentVariable("Path", "Machine")

        if ($machinePath -notlike "*$pgPath*") {

            [Environment]::SetEnvironmentVariable(
                "Path",
                "$machinePath;$pgPath",
                "Machine"
            )

            Write-Host "PostgreSQL PATH added permanently." -ForegroundColor Green
        }

    }
    else {
        throw "PostgreSQL bin directory not found: $pgPath"
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
    # Generate SSH key
    # =========================

    $email = Read-Host "Enter GitHub Key/Email label"

    ssh-keygen -t ed25519 -C $email

    Write-Host ""
    Write-Host "=========================================" -ForegroundColor Cyan
    Write-Host "COPY THIS SSH PUBLIC KEY TO GITHUB:" -ForegroundColor Yellow
    Write-Host "=========================================" -ForegroundColor Cyan

    Get-Content "$HOME\.ssh\id_ed25519.pub"

    Write-Host ""
    Write-Host "GitHub SSH Key Page:"
    Write-Host "https://github.com/settings/keys"
    Write-Host ""

    Start-Process "https://github.com/settings/keys"

    Read-Host "Press ENTER after adding the SSH key to GitHub"

    Write-Host ""
    Write-Host "Testing GitHub SSH connection..."
    ssh -T git@github.com

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
    Write-Host ""
    Read-Host "Press ENTER to exit"

}
catch {
    Write-Host ""
    Write-Host "=========================================" -ForegroundColor Red
    Write-Host "SETUP FAILED" -ForegroundColor Red
    Write-Host "=========================================" -ForegroundColor Red

    Write-Host ""
    Write-Host "Error Message:" -ForegroundColor Yellow
    Write-Host $_.Exception.Message -ForegroundColor Red

    Write-Host ""
    Write-Host "Full Error:" -ForegroundColor Yellow
    Write-Host $_ -ForegroundColor Red

    Write-Host ""
    Write-Host "Stack Trace:" -ForegroundColor Yellow
    Write-Host $_.ScriptStackTrace -ForegroundColor DarkGray

    Write-Host ""
    Read-Host "Press ENTER to exit"
}
finally {
    Stop-Transcript
}