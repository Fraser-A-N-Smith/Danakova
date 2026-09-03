# Starts the campaign vault and prints the share link for your players.
# (No $ErrorActionPreference = "Stop" on purpose -- see the note in
#  first-time-setup.ps1 about native stderr in Windows PowerShell 5.1.)
Set-Location $PSScriptRoot

if (-not (Test-Path ".env")) {
    Write-Host "No .env found. Run .\first-time-setup.ps1 first." -ForegroundColor Red
    exit 1
}

cmd /c "docker info >nul 2>&1"
if ($LASTEXITCODE -ne 0) {
    Write-Host "Docker isn't running. Open Docker Desktop, wait for 'Engine running', then retry." -ForegroundColor Red
    exit 1
}

Write-Host "Starting CollabMD..." -ForegroundColor Cyan
docker compose up -d
if ($LASTEXITCODE -ne 0) { Write-Host "Failed to start. See the error above." -ForegroundColor Red; exit 1 }

Write-Host "Waiting for the Cloudflare tunnel (up to 60s)..." -ForegroundColor Cyan
$url = $null
foreach ($i in 1..30) {
    Start-Sleep -Seconds 2
    $log = cmd /c "docker logs collabmd-tunnel 2>&1"
    $m = [regex]::Match(($log | Out-String), 'https://[a-z0-9-]+\.trycloudflare\.com')
    if ($m.Success) { $url = $m.Value; break }
}

$passLine = Select-String -Path ".env" -Pattern '^COLLABMD_PASSWORD=' | Select-Object -First 1
$pass = $passLine.Line.Split('=', 2)[1]

Write-Host ""
if ($url) {
    Write-Host "=== Send this to your players ===" -ForegroundColor Green
    Write-Host "  Link:     $url"
    Write-Host "  Password: $pass"
    Write-Host ""
    Write-Host "The link changes every restart. The password does not." -ForegroundColor DarkGray
    Set-Clipboard -Value "Campaign notes: $url`nPassword: $pass"
    Write-Host "(copied to your clipboard)" -ForegroundColor DarkGray
} else {
    Write-Host "Tunnel URL didn't appear in time. Check it by hand with:" -ForegroundColor Yellow
    Write-Host "  docker logs collabmd-tunnel"
    Write-Host "Your password is: $pass"
}
Write-Host ""
Write-Host "Your own local access: http://localhost:1234" -ForegroundColor DarkGray
Write-Host "Stop everything with:  .\stop-campaign.ps1" -ForegroundColor DarkGray
