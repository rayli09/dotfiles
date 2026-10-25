#!/usr/bin/env bash
set -euo pipefail
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$repo_root/scripts/tools-env.sh"
test_root="$(mktemp -d)"
trap 'rm -rf "$test_root"' EXIT

# Test the working tree in a separate source checkout, never the live collection.
python3 - "$repo_root" "$test_root/source" <<'COPY'
import shutil
import sys
from pathlib import Path
source = Path(sys.argv[1])
def ignored(directory, names):
    result = {name for name in names if name in {'.git', '.agents', '.tools', 'node_modules', '.DS_Store'}}
    if Path(directory) == source / 'agents':
        result.update(name for name in names if name == 'runtime' or name.startswith('.skills-stage-'))
    return result
shutil.copytree(source, sys.argv[2], ignore=ignored)
COPY
fixture="$(cd "$test_root/source" && pwd -P)"
mise trust "$fixture/mise.toml"
for phase in fresh repeat; do
  bash "$fixture/scripts/install-skills.sh"
  bash "$fixture/scripts/check-skills.sh"
  cmp "$repo_root/skills-lock.json" "$fixture/skills-lock.json"
  [[ ! -e "$fixture/.agents/skills" ]]
  printf 'ok   %s CLI skill restore and unchanged catalog\n' "$phase"
done
bash "$fixture/scripts/test-chezmoi.sh" "$fixture"

# Verification must catch changed content, even when all expected names exist.
cp "$fixture/agents/runtime/find-skills/SKILL.md" "$test_root/original-skill"
printf '\ncorruption\n' >> "$fixture/agents/runtime/find-skills/SKILL.md"
if bash "$fixture/scripts/check-skills.sh" > "$test_root/corrupt.log" 2>&1; then
  echo 'Corrupt skill content was accepted' >&2
  exit 1
fi
grep -q 'Content hash mismatch' "$test_root/corrupt.log"
cp "$test_root/original-skill" "$fixture/agents/runtime/find-skills/SKILL.md"

# Exercise the CLI's hash-rewrite behavior with one real pinned upstream skill.
# A failed restore must leave the prior runtime tree intact.
python3 - "$fixture/skills-lock.json" <<'CATALOG'
import json
import sys
from pathlib import Path
p = Path(sys.argv[1])
lock = json.loads(p.read_text())
entry = lock['skills']['find-skills']
entry['computedHash'] = '0' * 64
p.write_text(json.dumps({'version': 1, 'skills': {'find-skills': entry}}, indent=2) + '\n')
CATALOG
before="$(cksum "$fixture/agents/runtime/find-skills/SKILL.md")"
if bash "$fixture/scripts/install-skills.sh" > "$test_root/frozen.log" 2>&1; then
  echo 'A rewritten lock hash was accepted' >&2
  exit 1
fi
grep -q 'changed the approved catalog' "$test_root/frozen.log"
[[ "$(cksum "$fixture/agents/runtime/find-skills/SKILL.md")" == "$before" ]]

python3 - "$fixture/skills-lock.json" <<'FLOATING'
import json
import sys
from pathlib import Path
p = Path(sys.argv[1])
lock = json.loads(p.read_text())
lock['skills']['find-skills']['ref'] = 'main'
p.write_text(json.dumps(lock, indent=2) + '\n')
FLOATING
if bash "$fixture/scripts/install-skills.sh" > "$test_root/ref.log" 2>&1; then
  echo 'A floating Git reference was accepted' >&2
  exit 1
fi
grep -q 'full Git commit pin' "$test_root/ref.log"
cp "$repo_root/skills-lock.json" "$fixture/skills-lock.json"
mkdir -p "$fixture/agents/personal-skills/find-skills"
printf 'reserved custom name\n' > "$fixture/agents/personal-skills/find-skills/SKILL.md"
if bash "$fixture/scripts/install-skills.sh" > "$test_root/collision.log" 2>&1; then
  echo 'An upstream skill overwrote a custom name' >&2
  exit 1
fi
grep -q 'collides with custom skill' "$test_root/collision.log"
rm -r "$fixture/agents/personal-skills/find-skills"
bash "$fixture/scripts/check-skills.sh"
printf 'ok   corrupt content, rewritten hashes, and floating refs rejected without replacing runtime\n'

# A smaller approved catalog removes stale generated skills on deployment.
python3 - "$fixture/skills-lock.json" <<'SUBSET'
import json
import sys
from pathlib import Path
p = Path(sys.argv[1])
lock = json.loads(p.read_text())
p.write_text(json.dumps({'version': 1, 'skills': {'find-skills': lock['skills']['find-skills']}}, indent=2) + '\n')
SUBSET
bash "$fixture/scripts/install-skills.sh"
bash "$fixture/scripts/check-skills.sh"
[[ ! -e "$fixture/agents/runtime/cloudflare" ]]
printf 'ok   stale generated skills removed after a catalog change\n'
