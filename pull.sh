#!/bin/zsh
# Pull atelier apps — fast-forward each cloned repo from its remote.
# Apps are independent repos cloned by ./clone.sh; this just orchestrates.
#
#   ./pull.sh                pull every cloned app (bulk)
#   ./pull.sh <app>          pull one app
#   ./pull.sh --list         list apps that are cloned
#
# Missing clones are skipped with a hint (run ./clone.sh first).
set -e
cd "$(dirname "$0")"

# roster from apps.txt (strip comments / blanks)
typeset -a ROSTER
while IFS= read -r line; do
  line="${line%%#*}"; line="${line//[[:space:]]/}"
  [[ -n "$line" ]] && ROSTER+=("$line")
done < apps.txt

# which apps are actually cloned
typeset -a CLONED
for app in $ROSTER; do
  [[ -d "$app/.git" ]] && CLONED+=("$app")
done

if [[ "${1:-}" == "--list" || "${1:-}" == "-l" ]]; then
  for app in $CLONED; do echo "$app"; done
  exit 0
fi

pull_one() {
  local app="$1"
  if [[ ! -d "$app/.git" ]]; then
    echo "pull.sh: '$app' not cloned — run ./clone.sh first" >&2; return 2
  fi
  echo "↻ $app — git pull --ff-only"
  git -C "$app" pull --ff-only
}

if [[ $# -eq 0 ]]; then
  for app in $CLONED; do pull_one "$app"; done
  echo "✔ pull.sh done (${#CLONED} app(s))."
else
  pull_one "$1"
fi
