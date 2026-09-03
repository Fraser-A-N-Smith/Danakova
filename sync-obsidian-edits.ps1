# Docker on Windows does not forward filesystem events into the container, so
# CollabMD does not notice edits you make in Obsidian until it rescans the vault.
# Run this after editing in Obsidian to push those changes to your players.
# (Restarting only collabmd keeps the tunnel up, so the share link does NOT change.)
$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot
Write-Host "Rescanning vault..." -ForegroundColor Cyan
docker compose restart collabmd | Out-Null
Start-Sleep -Seconds 8
$count = (docker logs collabmd 2>&1 | Select-String 'Vault:\s+/data \((\d+) files\)' | Select-Object -Last 1)
Write-Host "Done. $count" -ForegroundColor Green
Write-Host "Players should refresh their browser tab." -ForegroundColor DarkGray
