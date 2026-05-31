$ErrorActionPreference = "Stop"

$script = Join-Path $PSScriptRoot "scripts\bootstrap-windows.ps1"

if (Test-Path $script) {
  & $script
} else {
  $url = "https://raw.githubusercontent.com/rayli09/dotfiles/main/scripts/bootstrap-windows.ps1"
  Invoke-Expression ((Invoke-WebRequest -UseBasicParsing $url).Content)
}
