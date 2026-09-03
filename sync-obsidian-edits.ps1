# Docker on Windows does not forward filesystem events into the container, so
# CollabMD does not notice edits you make in Obsidian until it rescans the vault.
# Run this after editing in Obsidian to push those changes to your players.
# Restarting only collabmd keeps the tunnel up, so the share link does NOT change.
Set-Location $PSScriptRoot

Write-Host "Rescanning the vault..." -ForegroundColor Cyan
docker compose restart collabmd
if ($LASTEXITCODE -ne 0) { Write-Host "Restart failed - is the vault running?" -ForegroundColor Red; exit 1 }

Start-Sleep -Seconds 8
$log = cmd /c "docker logs collabmd 2>&1"
$m = [regex]::Matches(($log | Out-String), 'Vault:\s+/data \((\d+) files\)')
if ($m.Count -gt 0) {
    $files = $m[$m.Count - 1].Groups[1].Value
    Write-Host "Done - CollabMD now sees $files files." -ForegroundColor Green
} else {
    Write-Host "Done." -ForegroundColor Green
}
Write-Host "Players should refresh their browser tab." -ForegroundColor DarkGray
