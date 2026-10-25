$ErrorActionPreference = "Stop"

function Has-Command {
  param([string]$Name)
  return [bool](Get-Command $Name -ErrorAction SilentlyContinue)
}

function Install-WinGetPackage {
  param([string]$Id)

  winget install --id $Id --exact --source winget --silent --accept-package-agreements --accept-source-agreements
}

function Add-ToPath {
  param([string]$Path)

  if ((Test-Path $Path) -and (($env:Path -split ";") -notcontains $Path)) {
    $env:Path = "$Path;$env:Path"
  }
}

function Install-SourceCodeProFont {
  $fontName = "Source Code Pro"
  $installed = Get-ChildItem "$env:WINDIR\Fonts", "$env:LOCALAPPDATA\Microsoft\Windows\Fonts" -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -like "*SourceCodePro*" -or $_.Name -like "*Source Code Pro*" } |
    Select-Object -First 1

  if ($installed) {
    return
  }

  $release = Invoke-RestMethod "https://api.github.com/repos/adobe-fonts/source-code-pro/releases/latest"
  $asset = $release.assets | Where-Object { $_.name -like "TTF*.zip" } | Select-Object -First 1
  if (-not $asset) {
    throw "Could not find latest Source Code Pro TTF release asset."
  }

  $tmp = Join-Path ([System.IO.Path]::GetTempPath()) "source-code-pro"
  $zip = Join-Path $tmp $asset.name
  Remove-Item -Recurse -Force $tmp -ErrorAction SilentlyContinue
  New-Item -ItemType Directory -Force $tmp | Out-Null
  Invoke-WebRequest -UseBasicParsing $asset.browser_download_url -OutFile $zip
  Expand-Archive -Force $zip $tmp

  $shell = New-Object -ComObject Shell.Application
  $fonts = $shell.Namespace(0x14)
  Get-ChildItem $tmp -Recurse -Include "*.ttf" | ForEach-Object {
    $fonts.CopyHere($_.FullName)
  }

  Write-Host "Installed $fontName."
}

function Install-EditorExtensions {
  foreach ($cmd in @("code", "cursor")) {
    if (Has-Command $cmd) {
      Get-Content (Join-Path (chezmoi source-path) "private_dot_config/vscode/extensions.txt") | ForEach-Object {
        $extension = $_.Trim()
        if ($extension -and -not $extension.StartsWith("#")) {
          & $cmd --install-extension $extension --force
          if ($LASTEXITCODE -ne 0) { throw "Failed to install $extension in $cmd" }
        }
      }
    }
  }
}

function Set-EditorSettings {
  param([string]$SettingsPath)

  $settingsDir = Split-Path $SettingsPath
  New-Item -ItemType Directory -Force $settingsDir | Out-Null

  if (Test-Path $SettingsPath) {
    $settings = Get-Content -Raw $SettingsPath | ConvertFrom-Json
  } else {
    $settings = [pscustomobject]@{}
  }

  $settings | Add-Member -Force -NotePropertyName "workbench.colorTheme" -NotePropertyValue "Dracula Theme"
  $settings | Add-Member -Force -NotePropertyName "editor.fontFamily" -NotePropertyValue "'Source Code Pro', Consolas, 'Courier New', monospace"
  $settings | Add-Member -Force -NotePropertyName "editor.fontLigatures" -NotePropertyValue $false
  $settings | Add-Member -Force -NotePropertyName "terminal.integrated.fontFamily" -NotePropertyValue "Source Code Pro"
  $settings | ConvertTo-Json -Depth 10 | Set-Content $SettingsPath
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
  git_email = "you@example.com"
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

Add-ToPath "$env:LOCALAPPDATA\Programs\Microsoft VS Code\bin"
Add-ToPath "$env:ProgramFiles\Microsoft VS Code\bin"
Add-ToPath "$env:LOCALAPPDATA\Programs\Cursor\resources\app\bin"
Add-ToPath "$env:ProgramFiles\Cursor\resources\app\bin"

Install-SourceCodeProFont
Install-EditorExtensions
Set-EditorSettings "$env:APPDATA\Code\User\settings.json"
Set-EditorSettings "$env:APPDATA\Cursor\User\settings.json"

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
