#!/bin/zsh
# Pull atelier apps — fast-forward each cloned repo in its ghq checkout.
#
#   ./pull.sh                pull every cloned app (bulk)
#   ./pull.sh <app>          pull one app
#   ./pull.sh --list         list apps that are cloned
#
# Missing clones are skipped with a hint (run ./clone.sh first).
set -e
cd "$(dirname "$0")"
source ./lib.sh
load_roster

# which apps are actually cloned in the ghq tree
typeset -a CLONED
for app in $ROSTER; do
  app_cloned "$app" && CLONED+=("$app")
done

if [[ "${1:-}" == "--list" || "${1:-}" == "-l" ]]; then
  for app in $CLONED; do echo "$app"; done
  exit 0
fi

pull_one() {
  local app="$1" dir
  dir="$(app_dir "$app")"
  if ! app_cloned "$app"; then
    echo "pull.sh: '$app' not cloned — run ./clone.sh first" >&2; return 2
  fi
  echo "↻ $app — git pull --ff-only"
  git -C "$dir" pull --ff-only
}

if [[ $# -eq 0 ]]; then
  for app in $CLONED; do pull_one "$app"; done
  echo "✔ pull.sh done (${#CLONED} app(s))."
else
  pull_one "$1"
fi
