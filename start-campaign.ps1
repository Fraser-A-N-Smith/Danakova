# Starts the campaign vault and prints the share link for your players.
$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

Write-Host "Starting CollabMD..." -ForegroundColor Cyan
docker compose up -d

Write-Host "Waiting for the Cloudflare tunnel..." -ForegroundColor Cyan
$url = $null
foreach ($i in 1..30) {
    Start-Sleep -Seconds 2
    $log = docker logs collabmd-tunnel 2>&1 | Out-String
    $m = [regex]::Match($log, 'https://[a-z0-9-]+\.trycloudflare\.com')
    if ($m.Success) { $url = $m.Value; break }
}

$pass = (Get-Content .env | Select-String '^COLLABMD_PASSWORD=').ToString().Split('=', 2)[1]

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
    Write-Host "Tunnel URL not found yet. Check with:" -ForegroundColor Yellow
    Write-Host "  docker logs collabmd-tunnel"
}
Write-Host ""
Write-Host "Your own local access: http://localhost:1234" -ForegroundColor DarkGray
Write-Host "Stop everything with:  .\stop-campaign.ps1" -ForegroundColor DarkGray
