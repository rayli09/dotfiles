#!/usr/bin/env bash
set -euo pipefail

source_path="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
test_root="$(mktemp -d)"
trap 'rm -rf "$test_root"' EXIT
mkdir -p "$test_root/bin" "$test_root/source/private_dot_config/vscode" "$test_root/opt/fzf" "$test_root/source/scripts"
printf '# Comment\n\ndracula-theme.theme-dracula\nexample.second' > "$test_root/source/private_dot_config/vscode/extensions.txt"

cat > "$test_root/bin/stub" <<'STUB'
#!/bin/bash
name="${0##*/}"
printf '%s %s\n' "$name" "$*" >> "$TEST_LOG"
if [[ "${TEST_FAIL:-}" == "$name $1" ]]; then
  exit 42
fi
case "$name" in
  chezmoi) printf '%s\n' "$TEST_SOURCE" ;;
  brew) if [[ "$1" == --prefix ]]; then printf '%s\n' "$TEST_PREFIX"; fi ;;
  sudo) "$@" ;;
esac
STUB
cat > "$test_root/source/scripts/install-tools.sh" <<'INSTALL'
#!/bin/bash
printf 'shared install\n' >> "$TEST_LOG"
if [[ "${TEST_FAIL:-}" == 'shared install' ]]; then exit 42; fi
INSTALL
cat > "$test_root/source/scripts/tools-env.sh" <<'ACTIVATE'
printf 'shared activate\n' >> "$TEST_LOG"
ACTIVATE
ln -s /bin/bash "$test_root/bin/bash"
chmod +x "$test_root/bin/stub"
for command in chezmoi brew mise npm code cursor corepack mas fzf sudo apt-get; do
  ln -s stub "$test_root/bin/$command"
done
printf '#!/bin/bash\nexit 0\n' > "$test_root/opt/fzf/install"
chmod +x "$test_root/opt/fzf/install"

run_script() {
  PATH="$test_root/bin" TEST_LOG="$test_root/calls" \
    TEST_SOURCE="$test_root/source" TEST_PREFIX="$test_root" TEST_FAIL="${2:-}" \
    /bin/bash "$source_path/scripts/$1" > "$test_root/output" 2>&1
}

for script in bootstrap-macos.sh update-macos.sh update-ubuntu.sh; do
  : > "$test_root/calls"
  run_script "$script"
  grep -q '^shared install$' "$test_root/calls"
  grep -q '^npm install -g wrangler@latest$' "$test_root/calls"
  if grep -Eq '^(mise |bun upgrade|uv self update|brew upgrade (bun|uv))' "$test_root/calls"; then
    echo "Shared tool ownership bypassed in $script" >&2
    exit 1
  fi
  if [[ "$script" != update-ubuntu.sh ]]; then
    for editor in code cursor; do
      printf '%s --install-extension dracula-theme.theme-dracula --force\n%s --install-extension example.second --force\n' "$editor" "$editor" > "$test_root/expected"
      grep "^$editor " "$test_root/calls" > "$test_root/actual"
      diff -u "$test_root/expected" "$test_root/actual"
    done
  fi
  for failure in 'shared install' 'npm install'; do
    if run_script "$script" "$failure"; then
      echo "$script hid failure: $failure" >&2
      exit 1
    fi
    if grep -q 'complete\.' "$test_root/output"; then
      echo "$script reported completion after a failure" >&2
      exit 1
    fi
  done
  if [[ "$script" != update-ubuntu.sh ]]; then
    if run_script "$script" 'cursor --install-extension'; then
      echo "$script hid an editor installation failure" >&2
      exit 1
    fi
  fi
  printf 'ok   %s: shared inputs, package ownership, and failure propagation\n' "$script"
done

for editor in Code Cursor; do
  chezmoi --source "$source_path" execute-template --file \
    "$source_path/private_Library/Application Support/$editor/User/settings.json.tmpl" > "$test_root/$editor.json"
done
cmp "$test_root/Code.json" "$test_root/Cursor.json"
printf 'ok   editor settings: both destinations render the shared template\n'
