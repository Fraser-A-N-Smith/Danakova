$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot
docker compose down
Write-Host "Campaign server stopped. Your notes are still on disk in .\vault" -ForegroundColor Green
