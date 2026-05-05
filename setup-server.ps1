# Fail fast
$ErrorActionPreference = "Stop"

Write-Host "Installing base tools..."

winget install --id Git.Git -e --source winget
winget install --id OpenJS.NodeJS.LTS -e
winget install --id PostgreSQL.PostgreSQL -e
winget install --id Nginx.Nginx -e

npm install -g pm2

Write-Host "Checking Version"

git -v
node -v
npm -v
pm2 -v
postgres -v
nginx -v


New-Item -ItemType Directory -Force -Path "C:\apps\insight"
Set-Location "C:\apps\insight"

Write-Host "Cloning Backend Repo"
git clone git@github.com:vishaltools-it/hana-insight.git backend

Write-Host "Cloning Frontend Repo"
git clone git@github.com:vishaltools-it/hana-insight-ui.git frontend