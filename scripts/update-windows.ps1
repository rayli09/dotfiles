$ErrorActionPreference = "Stop"

if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
  throw "winget is required. Install App Installer from the Microsoft Store first."
}

winget upgrade --all --include-unknown --silent --accept-package-agreements --accept-source-agreements

if (Get-Command bun -ErrorAction SilentlyContinue) {
  bun upgrade
}

if (Get-Command uv -ErrorAction SilentlyContinue) {
  uv self update
}

if (Get-Command mise -ErrorAction SilentlyContinue) {
  mise upgrade
  mise install
  $miseShims = Join-Path $env:LOCALAPPDATA "mise\shims"
  $env:Path = "$miseShims;$env:Path"
}

if (Get-Command npm -ErrorAction SilentlyContinue) {
  npm install -g wrangler@latest
  corepack enable
}

foreach ($cmd in @("code", "cursor")) {
  if (Get-Command $cmd -ErrorAction SilentlyContinue) {
    & $cmd --install-extension dracula-theme.theme-dracula --force
  }
}

Write-Host "Windows update complete."
