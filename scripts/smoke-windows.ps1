$ErrorActionPreference = "Stop"

$required = @(
  "chezmoi",
  "git",
  "gh",
  "op",
  "mise",
  "node",
  "npm",
  "bun",
  "uv",
  "python",
  "go",
  "wrangler",
  "cloudflared"
)

$missing = @()

foreach ($cmd in $required) {
  $found = Get-Command $cmd -ErrorAction SilentlyContinue
  if ($found) {
    Write-Host "ok   $cmd`: $($found.Source)"
  } else {
    Write-Host "miss $cmd"
    $missing += $cmd
  }
}

if ($missing.Count -gt 0) {
  throw "Missing commands: $($missing -join ', ')"
}

Write-Host "Windows smoke check passed."
