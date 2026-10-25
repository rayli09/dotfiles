#!/usr/bin/env bash
set -euo pipefail
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$repo_root/toolchain.env"
source "$repo_root/scripts/tools-env.sh"
cd "$repo_root"
require_version() {
  local expected="$1" actual="$2" tool="$3"
  [[ "$actual" == "$expected" ]] || { printf '%s: expected %s, got %s\n' "$tool" "$expected" "$actual" >&2; exit 1; }
  printf '%s %s\n' "$tool" "$actual"
}
require_version "v$NODE_VERSION" "$(node --version)" node
require_version "$NPM_VERSION" "$(npm --version)" npm
require_version "$BUN_VERSION" "$(bun --version)" bun
require_version "$PNPM_VERSION" "$(pnpm --version)" pnpm
require_version "$UV_VERSION" "$(uv --version | awk '{print $2}')" uv
require_version "go$GO_VERSION" "$(go version | awk '{print $3}')" go
require_version "$PYTHON_VERSION" "$(python3 --version | awk '{print $2}')" python
require_version "$OXLINT_VERSION" "$(oxlint --version | awk '{print $NF}')" oxlint
require_version "$OXFMT_VERSION" "$(oxfmt --version | awk '{print $NF}')" oxfmt
require_version "$TYPESCRIPT_VERSION" "$(tsc --version | awk '{print $NF}')" typescript
require_version "$RUFF_VERSION" "$(ruff --version | awk '{print $2}')" ruff
require_version "$TY_VERSION" "$(ty --version | awk '{print $2}')" ty

scratch_dir="$(mktemp -d)"
trap 'rm -rf "$scratch_dir"' EXIT
printf 'console.log("dotfiles-tools");\n' > "$scratch_dir/check.js"
node "$scratch_dir/check.js"
bun "$scratch_dir/check.js"
oxlint "$scratch_dir/check.js"
oxfmt --check "$scratch_dir/check.js"
printf 'const value: number = 42;\n' > "$scratch_dir/check.ts"
tsc --noEmit "$scratch_dir/check.ts"
printf 'value: int = 42\n' > "$scratch_dir/check.py"
python3 -m py_compile "$scratch_dir/check.py"
ruff check "$scratch_dir/check.py"
ty check "$scratch_dir/check.py"
printf 'package main\nimport "fmt"\nfunc main() { fmt.Println("dotfiles-tools") }\n' > "$scratch_dir/check.go"
go build -o "$scratch_dir/check-go" "$scratch_dir/check.go"
"$scratch_dir/check-go"
printf 'Shared tool checks passed.\n'
