#!/usr/bin/env bash
set -euo pipefail

failures=0

usage() {
  cat <<'EOF'
Usage: scripts/assert-macos-preferences.sh

Read macOS preferences and verify the values managed by scripts/macos-defaults.sh.
The checks are derived from `scripts/macos-defaults.sh --dry-run`, so a
preference added there is asserted here automatically.
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

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

writes=0
checks=0

# Turn one `+ defaults write ...` dry-run line into a check. The dry-run
# prints arguments %q-quoted; stripping the backslash escapes yields plain
# words for every value macos-defaults.sh currently writes.
check_write() {
  local line="$1"
  local body="${line#+ defaults write }"
  local clean="${body//\\/}"
  local -a words
  read -ra words <<< "$clean"

  local domain="${words[0]}"
  local key="${words[1]}"
  local type="${words[2]}"

  case "$type" in
    -bool)
      local expected=0
      [[ "${words[3]}" == "true" ]] && expected=1
      assert_default "$domain" "$key" "$expected"
      checks=$((checks + 1))
      ;;
    -int)
      assert_default "$domain" "$key" "${words[3]}"
      checks=$((checks + 1))
      ;;
    -string)
      assert_default "$domain" "$key" "${words[*]:3}"
      checks=$((checks + 1))
      ;;
    -dict-add)
      # Only com.apple.symbolichotkeys uses -dict-add; its entries are
      # nested plists, so they are read back with PlistBuddy instead.
      local id="${words[3]}"
      local enabled key_code char_code modifiers
      if [[ "$clean" =~ enabled\ =\ ([0-9]+) ]]; then
        enabled="${BASH_REMATCH[1]}"
      else
        fail "$domain $key $id: no enabled value in dry-run line: $line"
        return
      fi
      if [[ "$clean" =~ parameters\ =\ \(([0-9]+),\ ([0-9]+),\ ([0-9]+)\) ]]; then
        key_code="${BASH_REMATCH[1]}"
        char_code="${BASH_REMATCH[2]}"
        modifiers="${BASH_REMATCH[3]}"
      else
        fail "$domain $key $id: no parameters in dry-run line: $line"
        return
      fi
      assert_hotkey "$id" "$domain $key $id" "$enabled" "$key_code" "$char_code" "$modifiers"
      checks=$((checks + 1))
      ;;
    *)
      fail "unhandled defaults write type '$type' in dry-run line: $line"
      ;;
  esac
}

while IFS= read -r line; do
  case "$line" in
    '+ defaults write '*)
      writes=$((writes + 1))
      check_write "$line"
      ;;
  esac
done < <(bash "$script_dir/macos-defaults.sh" --dry-run)

if ((writes == 0)); then
  echo "No defaults writes found in macos-defaults.sh --dry-run output." >&2
  exit 1
fi

if ((checks != writes)); then
  printf "\nGenerated %d check(s) for %d managed write(s); coverage is incomplete.\n" "$checks" "$writes" >&2
  exit 1
fi

if ((failures)); then
  printf "\n%d preference assertion(s) failed.\n" "$failures" >&2
  exit 1
fi

echo "macOS preference assertions passed."
