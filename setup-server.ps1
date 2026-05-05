# Fail fast
$ErrorActionPreference = "Stop"

function Install-App($id) {
    Write-Host "Installing $id..."
    winget install --id $id -e --source winget --accept-package-agreements --accept-source-agreements
}

try {
    Write-Host "Installing base tools..."

    Install-App "Git.Git"
    Install-App "OpenJS.NodeJS.LTS"
    Install-App "PostgreSQL.PostgreSQL"
    Install-App "Nginx.Nginx"

    Write-Host "Refreshing environment variables..."
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" +
                [System.Environment]::GetEnvironmentVariable("Path","User")

    Write-Host "Installing PM2..."
    npm install -g pm2

    Write-Host "Checking versions..."

    git --version
    node -v
    npm -v
    pm2 -v
    psql --version
    nginx -v

    Write-Host "Setup completed successfully." -ForegroundColor Green
}
catch {
    Write-Host "ERROR OCCURRED:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
}

# New-Item -ItemType Directory -Force -Path "C:\apps\insight"
# Set-Location "C:\apps\insight"

# Write-Host "Cloning Backend Repo"
# git clone git@github.com:vishaltools-it/hana-insight.git backend

# Write-Host "Cloning Frontend Repo"
# git clone git@github.com:vishaltools-it/hana-insight-ui.git frontend