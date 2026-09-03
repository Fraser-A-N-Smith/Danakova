# Run this ONCE on a new machine. It creates your .env (passwords) and
# downloads the two containers. Safe to re-run: it will not overwrite .env.
#
# NOTE: this script deliberately does NOT use $ErrorActionPreference = "Stop".
# In Windows PowerShell 5.1, redirecting a native program's stderr turns each
# line into an error record, which would abort the script on harmless warnings.
# We check $LASTEXITCODE instead.
Set-Location $PSScriptRoot

Write-Host ""
Write-Host "Campaign vault - first time setup" -ForegroundColor Cyan
Write-Host ""

# --- 1. Is Docker there and running? ---------------------------------------
Write-Host "[1/3] Checking Docker..." -ForegroundColor Cyan
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Host "  Docker is not installed." -ForegroundColor Red
    Write-Host "  Install Docker Desktop from https://www.docker.com/products/docker-desktop/"
    Write-Host "  then run this script again."
    exit 1
}
# cmd /c keeps the stderr redirect outside PowerShell entirely.
cmd /c "docker info >nul 2>&1"
if ($LASTEXITCODE -ne 0) {
    Write-Host "  Docker is installed but not running." -ForegroundColor Red
    Write-Host "  Open Docker Desktop from the Start menu, wait until it says"
    Write-Host "  'Engine running', then run this script again."
    exit 1
}
Write-Host "  Docker is running." -ForegroundColor Green

# --- 2. Create .env if it does not exist ------------------------------------
Write-Host "[2/3] Setting up passwords..." -ForegroundColor Cyan
if (Test-Path ".env") {
    Write-Host "  .env already exists - leaving it alone." -ForegroundColor Yellow
} else {
    $words = @('anvil','bramble','cinder','dagger','ember','fathom','gilded','harrow',
               'ironwood','jester','kestrel','lantern','marrow','nimbus','obsidian','pyre',
               'quarry','rampart','sable','tundra','umber','vellum','warden','yarrow',
               'zephyr','basilisk','cairn','drake','feywild','gloam','hearth','thorn')
    $pass = "$(Get-Random $words)-$(Get-Random $words)-$(Get-Random $words)-$(Get-Random -Minimum 100 -Maximum 999)"

    $bytes = New-Object byte[] 32
    [System.Security.Cryptography.RandomNumberGenerator]::Create().GetBytes($bytes)
    $secret = -join ($bytes | ForEach-Object { $_.ToString('x2') })

    $body = @"
# The password you give your players.
COLLABMD_PASSWORD=$pass

# Signing key for login sessions. Rotating it logs everyone out.
COLLABMD_SESSION_SECRET=$secret
"@
    # Write without a BOM -- docker compose mis-parses the first line if one is present.
    [System.IO.File]::WriteAllText(
        (Join-Path $PSScriptRoot ".env"),
        $body,
        (New-Object System.Text.UTF8Encoding($false))
    )
    Write-Host "  Created .env with password: $pass" -ForegroundColor Green
}

# --- 3. Download the containers ---------------------------------------------
Write-Host "[3/3] Downloading CollabMD and the Cloudflare tunnel..." -ForegroundColor Cyan
Write-Host "  (a few hundred MB, only happens once)" -ForegroundColor DarkGray
docker compose pull
if ($LASTEXITCODE -ne 0) {
    Write-Host "  Download failed. Check your internet connection and try again." -ForegroundColor Red
    exit 1
}
Write-Host "  Done." -ForegroundColor Green

Write-Host ""
Write-Host "Setup complete. Start the vault with:" -ForegroundColor Green
Write-Host "  .\start-campaign.ps1"
Write-Host ""
