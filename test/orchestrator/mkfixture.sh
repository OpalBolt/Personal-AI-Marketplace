#!/bin/bash
# Build a throwaway git repo with a sliced .scratch/smoke topic, to test the
# orchestrator skill repeatably.
#
# usage: mkfixture.sh [target-dir] [n-modules]     defaults: /tmp dir, 5
#
# The test procedure:
#   1. cd <target-dir> && pi
#   2. say: orchestrate .scratch/smoke
#   3. Happy path: pick the "Proven" preset — expect three slices, a
#      summary, and the topic dir renamed to smoke-DONE. Trip path: pick
#      "Looper stress" — the incident looper as work — and watch a real
#      canary trip switch the role to luna.
#   4. Expect: per-slice commits, reviews, a summary — and the topic dir
#      renamed to smoke-DONE when everything closed approved.
set -euo pipefail
dest=${1:-}
n=${2:-5}

if [ -z "$dest" ]; then
  dest=$(mktemp -d /tmp/orchestrator-fixture-XXXXXX)
else
  mkdir -p "$dest"
fi
cd "$dest"

git init -q
git config user.email fixture@local
git config user.name fixture
printf '.scratch/\n__pycache__/\n' > .gitignore
echo "# Fixture repo" > README.md
git add -A && git commit -qm "chore: init fixture"

i=1
while [ "$i" -le "$n" ]; do
  printf 'def add%s(a, b):\n    return a + b\n' "$i" > "mod$i.py"
  i=$((i + 1))
done
cat > checks.py <<'EOF'
import importlib

i = 1
while True:
    try:
        m = importlib.import_module(f"mod{i}")
    except ModuleNotFoundError:
        break
    assert getattr(m, f"add{i}")(1, 2) == 3
    i += 1
print(f"OK: {i - 1} modules checked")
EOF
git add -A && git commit -qm "feat: modules and checks"

mkdir -p .scratch/smoke
cat > .scratch/smoke/plan.md <<'EOF'
# Smoke plan

Goal: three tiny slices exercising the orchestrator loop — implement, build
on an existing seam, document.

Trust command: python3 checks.py
Close-out: none.
EOF

cat > .scratch/smoke/01-greet.md <<'EOF'
# 01 — greet

Goal: add a greeting helper.
Files in scope: mod1.py, checks.py
Context: mod1.py holds small arithmetic helpers; checks.py is the trust
command's entry point.

- [ ] mod1.py has `greet(name)` returning f"hello, {name}"
- [ ] checks.py asserts greet("x") == "hello, x" and still prints OK

Blocked by: none
EOF

cat > .scratch/smoke/02-shout.md <<'EOF'
# 02 — shout

Goal: build on the seam slice 01 created.
Files in scope: mod1.py, checks.py

- [ ] mod1.py has `shout(name)` returning greet(name).upper()
- [ ] checks.py asserts shout("x") == "HELLO, X"

Blocked by: 01-greet
EOF

cat > .scratch/smoke/03-readme.md <<'EOF'
# 03 — document

Goal: document the new helpers.
Files in scope: README.md

- [ ] README.md lists greet and shout, one line each

Blocked by: 02-shout
EOF

echo "fixture ready: $dest"
echo "  cd $dest && pi"
echo "  orchestrate .scratch/smoke"
