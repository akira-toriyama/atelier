#!/bin/zsh
# Run atelier apps — delegates to each app's own run.sh in its ghq checkout.
# Apps are independent repos fetched by ./clone.sh into the ghq tree; this
# just orchestrates.
#
#   ./run.sh                 run every app in the background (bulk)
#                            logs → /tmp/atelier-<app>.run.log
#   ./run.sh <app> [args…]   run one app in the foreground (args passthrough)
#   ./run.sh --list          list apps that have a run.sh
#
set -e
cd "$(dirname "$0")"
source ./lib.sh
load_roster

# which apps actually ship a run.sh (in their ghq checkout)
typeset -a RUNNABLE
for app in $ROSTER; do
  [[ -f "$(app_dir "$app")/run.sh" ]] && RUNNABLE+=("$app")
done

if [[ "${1:-}" == "--list" || "${1:-}" == "-l" ]]; then
  for app in $RUNNABLE; do echo "$app"; done
  exit 0
fi

# no args (or --all) → bulk launch every runnable app in the background
if [[ $# -eq 0 || "${1:-}" == "--all" ]]; then
  for app in $RUNNABLE; do
    dir="$(app_dir "$app")"
    log="/tmp/atelier-$app.run.log"
    echo "▶ $app → $log"
    ( cd "$dir" && exec ./run.sh ) >"$log" 2>&1 &
  done
  echo "launched ${#RUNNABLE} app(s) in the background."
  exit 0
fi

# single app → foreground, pass args straight through to its run.sh
app="$1"; shift
dir="$(app_dir "$app")"
if ! app_cloned "$app"; then
  echo "run.sh: '$app' not cloned — run ./clone.sh first" >&2; exit 2
fi
if [[ ! -f "$dir/run.sh" ]]; then
  echo "run.sh: '$app' has no run.sh (library or non-daemon app)" >&2; exit 2
fi
echo "▶ $app run.sh $*"
exec "$dir/run.sh" "$@"
