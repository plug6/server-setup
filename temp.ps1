# =========================
# Generate SSH key
# =========================

$email = Read-Host "Enter GitHub email label"

ssh-keygen -t ed25519 -C $email

Write-Host ""
Write-Host "COPY THIS SSH PUBLIC KEY TO GITHUB:" -ForegroundColor Yellow

Get-Content "$HOME\.ssh\id_ed25519.pub"

Start-Process "https://github.com/settings/keys"

Read-Host "Press ENTER after adding the SSH key to GitHub"

Write-Host "Testing GitHub SSH connection..."
ssh -T git@github.com