#!/usr/bin/env bash
set -euo pipefail
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$repo_root/scripts/tools-env.sh"
cd "$repo_root"
python3 - "$repo_root/mise.toml" <<'VERSIONS'
import subprocess
import sys
import tomllib

with open(sys.argv[1], "rb") as config:
    tools = tomllib.load(config)["tools"]
checks = {
    "node": (["node", "--version"], lambda text: text.strip().removeprefix("v")),
    "npm": (["npm", "--version"], str.strip),
    "bun": (["bun", "--version"], str.strip),
    "aqua:pnpm/pnpm": (["pnpm", "--version"], str.strip),
    "aqua:astral-sh/uv": (["uv", "--version"], lambda text: text.split()[1]),
    "go": (["go", "version"], lambda text: text.split()[2].removeprefix("go")),
    "python": (["python3", "--version"], lambda text: text.split()[1]),
    "aqua:oxc-project/oxc/oxlint": (["oxlint", "--version"], lambda text: text.split()[-1]),
    "npm:oxfmt": (["oxfmt", "--version"], lambda text: text.split()[-1]),
    "npm:skills": (["skills", "--version"], str.strip),
    "npm:typescript": (["tsc", "--version"], lambda text: text.split()[-1]),
    "aqua:astral-sh/ruff": (["ruff", "--version"], lambda text: text.split()[1]),
    "aqua:astral-sh/ty": (["ty", "--version"], lambda text: text.split()[1]),
}
assert tools.keys() == checks.keys(), "Update executable checks when changing tools"
for name, (command, parse) in checks.items():
    actual = parse(subprocess.check_output(command, text=True))
    assert actual == tools[name], f"{name}: expected {tools[name]}, got {actual}"
    print(f"{name} {actual}")
VERSIONS

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
