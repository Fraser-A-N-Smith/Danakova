# Shuts the campaign vault down. Your notes stay on disk -- nothing is lost.
Set-Location $PSScriptRoot
docker compose down
if ($LASTEXITCODE -ne 0) { Write-Host "Shutdown reported a problem, see above." -ForegroundColor Yellow; exit 1 }
Write-Host ""
Write-Host "Stopped. Your notes are safe in .\vault" -ForegroundColor Green
Write-Host "Next start will have a NEW share link (the password stays the same)." -ForegroundColor DarkGray
