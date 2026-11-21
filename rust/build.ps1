# Compile Armoire Designer en Rust et crée l'installateur Velopack.
# Usage :  .\build.ps1 -Version 1.0.0 [-UpdateUrl https://mon-serveur/armoire]
param(
  [string]$Version = "1.0.0",
  [string]$UpdateUrl = ""
)
$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

# 1. Reprendre la dernière version de l'interface (dossier parent)
New-Item -ItemType Directory -Force "assets" | Out-Null
if (Test-Path "..\ArmoireDesigner.html") { Copy-Item "..\ArmoireDesigner.html" "assets\ArmoireDesigner.html" -Force }
if (Test-Path "..\ArmoireDesigner.ico")  { Copy-Item "..\ArmoireDesigner.ico"  "assets\ArmoireDesigner.ico" -Force }
if (-not (Test-Path "assets\ArmoireDesigner.html")) { throw "ArmoireDesigner.html introuvable (attendu dans le dossier parent)" }
if (-not (Get-Command cargo -ErrorAction SilentlyContinue)) { throw "Rust n'est pas installé : https://rustup.rs" }

# 2. Compiler
# cargo/vpk écrivent leur progression sur stderr : on juge sur le code de sortie, pas sur stderr.
$ErrorActionPreference = "Continue"
$env:ARMOIRE_UPDATE_URL = $UpdateUrl
cargo build --release
if ($LASTEXITCODE -ne 0) { throw "Échec de la compilation Rust" }

# 3. Outil Velopack (nécessite le SDK .NET 8)
if (-not (Get-Command vpk -ErrorAction SilentlyContinue)) {
  dotnet tool update -g vpk --add-source https://api.nuget.org/v3/index.json
  if ($LASTEXITCODE -ne 0) { throw "Installation de vpk impossible" }
  $env:PATH += ";$env:USERPROFILE\.dotnet\tools"
}

# 4. Empaqueter : crée Releases\ArmoireDesigner-win-Setup.exe + paquets de mise à jour
$pub = "target\release\publish"
if (Test-Path $pub) { Remove-Item -Recurse -Force $pub }
New-Item -ItemType Directory -Force $pub | Out-Null
Copy-Item "target\release\ArmoireDesigner.exe" $pub -Force
$icon = @()
if (Test-Path "assets\ArmoireDesigner.ico") { $icon = @("--icon", "assets\ArmoireDesigner.ico") }
vpk pack --packId ArmoireDesigner --packVersion $Version --packDir $pub `
  --mainExe ArmoireDesigner.exe --packTitle "Armoire Designer" --runtime win-x64 `
  --outputDir Releases @icon
if ($LASTEXITCODE -ne 0) { throw "Échec de l'empaquetage Velopack (la version $Version existe peut-être déjà dans Releases : augmenter -Version)" }

# 5. Version portable : un seul exe, sans installation, données dans .\ArmoireDesigner-donnees
$env:ARMOIRE_PORTABLE = "1"
$env:ARMOIRE_UPDATE_URL = ""
cargo build --release --target-dir target\portable
$cargoExit = $LASTEXITCODE
Remove-Item Env:ARMOIRE_PORTABLE
if ($cargoExit -ne 0) { throw "Échec de la compilation portable" }
Copy-Item "target\portable\release\ArmoireDesigner.exe" "Releases\ArmoireDesigner-Portable.exe" -Force
Write-Host "Version portable : $PSScriptRoot\Releases\ArmoireDesigner-Portable.exe" -ForegroundColor Green
Write-Host "`nInstallateur : $PSScriptRoot\Releases\ArmoireDesigner-win-Setup.exe" -ForegroundColor Green
