#!/usr/bin/env bash
# Lifecycle for one slice's linked worktree, so the orchestrator skill never
# inlines git: create branched at HEAD, merge back into the main checkout,
# stage conflict resolution inside the worktree, clean up, crash-prune.
# usage: worktree.sh new <repo> <topic-slug> <slice-slug> [run-id]
#          -> prints the worktree path
#        worktree.sh merge <repo> <worktree-path>
#          -> prints ff | merge-commit | conflict (conflict: main clean, exit 1)
#        worktree.sh resolve <repo> <worktree-path>
#          -> merges main into the slice branch in the worktree; prints
#             conflict when markers land (the worker resolves by editing)
#        worktree.sh clean <repo> <worktree-path>
#        worktree.sh prune <repo> [topic-slug]
#          -> drop the topic's run-id dirs holding no registered worktree
#        worktree.sh --selftest
set -euo pipefail

die() { echo "worktree.sh: $*" >&2; exit 1; }

cmd_new() {
  repo=$(cd "$1" && pwd)
  topic=$2
  slice=$3
  runid=${4:-}
  root=$repo/.scratch/worktrees
  if [ -z "$runid" ]; then
    # retry loop so a repeated topic or a crashed run's leftovers never collide
    while :; do
      runid=$(head -c4 /dev/urandom | od -An -tx1 | tr -d ' \n')
      [ -e "$root/$topic-$runid" ] || break
    done
  fi
  branch="wt-$topic-$runid-$slice"
  wt="$root/$topic-$runid/$slice"
  git -C "$repo" worktree add -b "$branch" "$wt" >/dev/null
  echo "$wt"
}

abort_conflict() {
  repo=$1
  # MERGE_HEAD present = merge actually started; abort restores a clean main
  git -C "$repo" rev-parse -q --verify MERGE_HEAD >/dev/null && git -C "$repo" merge --abort
  echo conflict
  exit 1
}

cmd_merge() {
  repo=$(cd "$1" && pwd)
  wt=$2
  branch=$(git -C "$wt" symbolic-ref --quiet --short HEAD) || die "no branch checked out in $wt"
  if git -C "$repo" merge-base --is-ancestor HEAD "$branch"; then
    git -C "$repo" merge --ff-only --no-edit "$branch" >/dev/null && echo ff || abort_conflict "$repo"
  else
    git -C "$repo" merge --no-edit "$branch" >/dev/null && echo merge-commit || abort_conflict "$repo"
  fi
}

cmd_resolve() {
  repo=$(cd "$1" && pwd)
  wt=$2
  # branch name when main is on one, commit hash for detached HEAD
  ref=$(git -C "$repo" symbolic-ref --quiet --short HEAD || git -C "$repo" rev-parse HEAD)
  if ! git -C "$wt" merge --no-edit "$ref" >/dev/null; then
    # conflicts are the expected outcome here: markers stay in the worktree
    # for the worker, so only a failure WITHOUT a started merge is an error
    git -C "$wt" rev-parse -q --verify MERGE_HEAD >/dev/null || die "merge failed without conflicts in $wt"
    echo conflict
  fi
}

cmd_clean() {
  repo=$(cd "$1" && pwd)
  wt=$2
  branch=$(git -C "$wt" symbolic-ref --quiet --short HEAD 2>/dev/null || true)
  git -C "$repo" worktree remove --force "$wt"
  if [ -n "$branch" ]; then
    git -C "$repo" branch -q -D "$branch"
  fi
}

cmd_prune() {
  repo=$(cd "$1" && pwd)
  topic=${2:-}
  root=$repo/.scratch/worktrees
  git -C "$repo" worktree prune
  [ -d "$root" ] || return 0
  for d in "$root"/*/; do
    [ -d "$d" ] || continue
    if [ -n "$topic" ]; then
      case "${d%/}" in */"$topic"-*) ;; *) continue ;; esac
    fi
    # keep a run-id dir only while a registered worktree lives under it
    if git -C "$repo" worktree list --porcelain | grep -q "^worktree ${d%/}/"; then
      continue
    fi
    rm -rf "$d"
  done
}

selftest() {
  root=$(cd "$(dirname "$0")/../.." && pwd)
  mkdir -p "$root/.scratch"
  # fixture repo lives under .scratch: the sandbox only grants writes there
  fx=$(mktemp -d "$root/.scratch/wt-selftest.XXXXXX")
  trap 'rm -rf "$fx"' EXIT

  git -C "$fx" init -q
  git -C "$fx" config user.email t@t
  git -C "$fx" config user.name t
  echo .scratch/ >"$fx/.gitignore"
  echo base >"$fx/f.txt"
  git -C "$fx" add .
  git -C "$fx" commit -qm init

  expect() { [ "$1" = "$2" ] || die "selftest: want '$1' got '$2'"; }

  # fast-forward merge-back
  wt=$("$0" new "$fx" t1 alpha)
  git -C "$wt" commit --allow-empty -qm "slice a"
  expect ff "$("$0" merge "$fx" "$wt")"

  # merge-commit merge-back (main advanced first)
  wt=$("$0" new "$fx" t1 beta)
  git -C "$fx" commit --allow-empty -qm "main moved"
  git -C "$wt" commit --allow-empty -qm "slice b"
  expect merge-commit "$("$0" merge "$fx" "$wt")"

  # conflicted merge-back: abort, main clean, nonzero exit
  wt=$("$0" new "$fx" t1 gamma)
  echo main >"$fx/f.txt"
  git -C "$fx" commit -qam "main edit"
  echo slice >"$wt/f.txt"
  git -C "$wt" commit -qam "slice edit"
  if out=$("$0" merge "$fx" "$wt" 2>/dev/null); then rc=0; else rc=$?; fi
  expect 1 "$rc"
  expect conflict "$out"
  [ -z "$(git -C "$fx" status --porcelain)" ] || die "selftest: main dirty after aborted merge"

  # resolve inside the worktree, commit the fix, retry merges back as ff
  expect conflict "$("$0" resolve "$fx" "$wt")"
  grep -q '^<<<<<<<' "$wt/f.txt" || die "selftest: no conflict markers in worktree"
  echo resolved >"$wt/f.txt"
  git -C "$wt" commit -qam "resolve"
  expect ff "$("$0" merge "$fx" "$wt")"

  # two bare new calls, same topic and slice slug: run-ids must differ
  a=$("$0" new "$fx" dup same)
  b=$("$0" new "$fx" dup same)
  [ "$a" != "$b" ] || die "selftest: run-id collision ($a)"

  # clean drops worktree+branch; prune drops the emptied run-id dir but
  # keeps the one still holding a registered worktree
  "$0" clean "$fx" "$a"
  [ ! -e "$a" ] || die "selftest: clean left $a behind"
  "$0" prune "$fx" dup
  [ ! -e "$(dirname "$a")" ] || die "selftest: prune left $(dirname "$a") behind"
  [ -e "$(dirname "$b")" ] || die "selftest: prune removed a live run-id dir"

  echo ok
}

case ${1:-} in
  new) shift; cmd_new "$@" ;;
  merge) shift; cmd_merge "$@" ;;
  resolve) shift; cmd_resolve "$@" ;;
  clean) shift; cmd_clean "$@" ;;
  prune) shift; cmd_prune "$@" ;;
  --selftest) selftest ;;
  *) die "usage: worktree.sh new|merge|resolve|clean|prune <repo> ... | --selftest (details in header)" ;;
esac
