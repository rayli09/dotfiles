$ErrorActionPreference = "Stop"

function Has-Command {
  param([string]$Name)
  return [bool](Get-Command $Name -ErrorAction SilentlyContinue)
}

function Install-WinGetPackage {
  param([string]$Id)

  winget install --id $Id --exact --source winget --silent --accept-package-agreements --accept-source-agreements
}

$repo = "https://github.com/rayli09/dotfiles.git"

if (-not (Has-Command winget)) {
  throw "winget is required. Install App Installer from the Microsoft Store first."
}

if (-not (Has-Command chezmoi)) {
  $localBin = Join-Path $HOME ".local\bin"
  New-Item -ItemType Directory -Force $localBin | Out-Null
  Invoke-Expression "&{$(Invoke-RestMethod 'https://get.chezmoi.io/ps1')} -b '$localBin'"
  $env:Path = "$localBin;$env:Path"
}

if (-not (Test-Path "$HOME\.config\chezmoi\chezmoi.toml")) {
  New-Item -ItemType Directory -Force "$HOME\.config\chezmoi" | Out-Null
  @"
[data]
  git_name = "Ruize Li"
  git_email = "rl3250@columbia.edu"
  work_email = ""
"@ | Set-Content "$HOME\.config\chezmoi\chezmoi.toml"
}

chezmoi source-path *> $null
if ($LASTEXITCODE -eq 0) {
  chezmoi update --apply
} else {
  chezmoi init --apply $repo
}

$packages = @(
  "AgileBits.1Password",
  "AgileBits.1Password.CLI",
  "Git.Git",
  "GitHub.cli",
  "jdx.mise",
  "Microsoft.PowerShell",
  "Microsoft.VisualStudioCode",
  "Anysphere.Cursor",
  "OpenJS.NodeJS",
  "Python.Python.3.14",
  "GoLang.Go",
  "Astral.UV",
  "Oven-sh.Bun",
  "Cloudflare.cloudflared",
  "Docker.DockerDesktop",
  "Microsoft.WindowsTerminal",
  "Microsoft.PowerToys",
  "Google.Chrome",
  "SlackTechnologies.Slack",
  "Zoom.Zoom",
  "Discord.Discord",
  "Figma.Figma",
  "Notion.Notion",
  "Postman.Postman"
)

foreach ($package in $packages) {
  Install-WinGetPackage $package
}

if (Has-Command mise) {
  mise install
  $miseShims = Join-Path $env:LOCALAPPDATA "mise\shims"
  $env:Path = "$miseShims;$env:Path"
}

if (Has-Command npm) {
  npm install -g wrangler@latest
  corepack enable
}

Write-Host "Windows bootstrap complete. Restart your terminal."
