#!/usr/bin/env bash
set -euo pipefail

failures=0

usage() {
  cat <<'EOF'
Usage: scripts/assert-macos-preferences.sh

Read macOS preferences and verify the values managed by scripts/macos-defaults.sh.
This script does not change system settings.
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "macOS preference assertions require Darwin." >&2
  exit 1
fi

pass() {
  printf "ok   %s\n" "$*"
}

fail() {
  printf "fail %s\n" "$*" >&2
  failures=$((failures + 1))
}

read_default() {
  local domain="$1"
  local key="$2"

  defaults read "$domain" "$key" 2>/dev/null || true
}

assert_default() {
  local domain="$1"
  local key="$2"
  local expected="$3"
  local actual

  actual="$(read_default "$domain" "$key")"
  if [[ "$actual" == "$expected" ]]; then
    pass "$domain $key = $expected"
  else
    fail "$domain $key expected '$expected', got '${actual:-<unset>}'"
  fi
}

assert_hotkey() {
  local id="$1"
  local label="$2"
  local enabled="$3"
  local key_code="$4"
  local char_code="$5"
  local modifiers="$6"
  local plist="$HOME/Library/Preferences/com.apple.symbolichotkeys.plist"
  local actual_enabled
  local actual_key_code
  local actual_char_code
  local actual_modifiers

  actual_enabled="$(/usr/libexec/PlistBuddy -c "Print :AppleSymbolicHotKeys:$id:enabled" "$plist" 2>/dev/null || true)"
  actual_key_code="$(/usr/libexec/PlistBuddy -c "Print :AppleSymbolicHotKeys:$id:value:parameters:0" "$plist" 2>/dev/null || true)"
  actual_char_code="$(/usr/libexec/PlistBuddy -c "Print :AppleSymbolicHotKeys:$id:value:parameters:1" "$plist" 2>/dev/null || true)"
  actual_modifiers="$(/usr/libexec/PlistBuddy -c "Print :AppleSymbolicHotKeys:$id:value:parameters:2" "$plist" 2>/dev/null || true)"

  if [[ "$actual_enabled" == "$enabled" && "$actual_key_code" == "$key_code" && "$actual_char_code" == "$char_code" && "$actual_modifiers" == "$modifiers" ]]; then
    pass "$label"
  else
    fail "$label expected enabled=$enabled parameters=($key_code,$char_code,$modifiers), got enabled=${actual_enabled:-<unset>} parameters=(${actual_key_code:-<unset>},${actual_char_code:-<unset>},${actual_modifiers:-<unset>})"
  fi
}

assert_default NSGlobalDomain AppleShowAllExtensions "1"
assert_default com.apple.finder AppleShowAllFiles "1"
assert_default com.apple.finder ShowPathbar "1"
assert_default com.apple.finder ShowStatusBar "1"
assert_default com.apple.finder FXEnableExtensionChangeWarning "0"
assert_default com.apple.dock autohide "1"
assert_default com.apple.dock show-recents "0"
assert_default com.apple.dock mru-spaces "0"
assert_default NSGlobalDomain ApplePressAndHoldEnabled "0"
assert_default NSGlobalDomain KeyRepeat "2"
assert_default NSGlobalDomain InitialKeyRepeat "15"
assert_default com.apple.screencapture type "png"
assert_default com.apple.screencapture show-thumbnail "0"
assert_default com.apple.screensaver askForPassword "1"
assert_default com.apple.screensaver askForPasswordDelay "0"
assert_default com.apple.Terminal SecureKeyboardEntry "1"

assert_hotkey 64 "Spotlight search: Cmd-Space" "1" "32" "49" "1048576"
assert_hotkey 65 "Finder search window: Cmd-Option-Space" "1" "32" "49" "1572864"
assert_hotkey 60 "Previous input source: Ctrl-Space" "1" "32" "49" "262144"
assert_hotkey 61 "Next input source: Ctrl-Option-Space" "1" "32" "49" "786432"

if ((failures)); then
  printf "\n%d preference assertion(s) failed.\n" "$failures" >&2
  exit 1
fi

echo "macOS preference assertions passed."
