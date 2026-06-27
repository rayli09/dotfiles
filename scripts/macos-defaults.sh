#!/usr/bin/env bash
set -euo pipefail

dry_run=false

usage() {
  cat <<'EOF'
Usage: scripts/macos-defaults.sh [--dry-run]

Apply opinionated macOS preferences for a developer workstation.

Options:
  --dry-run   Print commands without changing the system.
  -h, --help  Show this help.
EOF
}

while (($#)); do
  case "$1" in
    --dry-run)
      dry_run=true
      ;;
    -h | --help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
  shift
done

log() {
  printf "\n==> %s\n" "$*"
}

run() {
  if [[ "$dry_run" == true ]]; then
    printf '+'
    printf ' %q' "$@"
    printf '\n'
  else
    "$@"
  fi
}

restart_process() {
  if [[ "$dry_run" == true ]]; then
    run killall "$1"
  else
    killall "$1" 2>/dev/null || true
  fi
}

if [[ "$(uname -s)" != "Darwin" && "$dry_run" != true ]]; then
  echo "macOS defaults can only be applied on Darwin. Use --dry-run for validation elsewhere." >&2
  exit 1
fi

log "Finder"
run defaults write NSGlobalDomain AppleShowAllExtensions -bool true
run defaults write com.apple.finder AppleShowAllFiles -bool true
run defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"
run defaults write com.apple.finder ShowPathbar -bool true
run defaults write com.apple.finder ShowStatusBar -bool true
run defaults write com.apple.finder _FXShowPosixPathInTitle -bool true
run defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
run defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
run defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

log "Dock"
run defaults write com.apple.dock autohide -bool true
run defaults write com.apple.dock show-recents -bool false
run defaults write com.apple.dock mru-spaces -bool false
run defaults write com.apple.dock tilesize -int 48

log "Keyboard and input"
run defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
run defaults write NSGlobalDomain KeyRepeat -int 2
run defaults write NSGlobalDomain InitialKeyRepeat -int 15
run defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
run defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
run defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false
run defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
run defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

log "Keyboard shortcuts"
# Restore Spotlight to Cmd-Space and move input source switching to Ctrl-Space.
run defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 64 "{ enabled = 1; value = { parameters = (32, 49, 1048576); type = standard; }; }"
run defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 65 "{ enabled = 1; value = { parameters = (32, 49, 1572864); type = standard; }; }"
run defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 60 "{ enabled = 1; value = { parameters = (32, 49, 262144); type = standard; }; }"
run defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 61 "{ enabled = 1; value = { parameters = (32, 49, 786432); type = standard; }; }"

log "Trackpad and mouse"
run defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
run defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
run defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
run defaults write NSGlobalDomain AppleEnableMouseSwipeNavigateWithScrolls -bool false
run defaults write NSGlobalDomain AppleEnableSwipeNavigateWithScrolls -bool false

log "Screenshots"
run mkdir -p "$HOME/Pictures/Screenshots"
run defaults write com.apple.screencapture location -string "$HOME/Pictures/Screenshots"
run defaults write com.apple.screencapture type -string "png"
run defaults write com.apple.screencapture show-thumbnail -bool false

log "Security and privacy nudges"
run defaults write com.apple.screensaver askForPassword -int 1
run defaults write com.apple.screensaver askForPasswordDelay -int 0

log "Terminal"
run defaults write com.apple.Terminal SecureKeyboardEntry -bool true

log "Applying changes"
restart_process Finder
restart_process Dock
restart_process SystemUIServer

cat <<'EOF'

Manual checks still required:
- System Settings > Privacy & Security: enable FileVault and Firewall if desired.
- System Settings > Touch ID & Password: enable Apple Watch or Touch ID unlock if desired.
- Grant Terminal, editors, and automation tools any required Privacy permissions.
- Sign into 1Password, GitHub CLI, Cloudflare/Wrangler, browsers, and editors.
EOF
