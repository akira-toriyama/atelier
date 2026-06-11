#!/bin/zsh
# Stop atelier apps — delegates to each app's own stop.sh.
#
#   ./stop.sh            stop every app (bulk)
#   ./stop.sh <app>      stop one app
#   ./stop.sh --list     list apps that have a stop.sh
#
set -e
cd "$(dirname "$0")"

# roster from apps.txt (strip comments / blanks)
typeset -a ROSTER
while IFS= read -r line; do
  line="${line%%#*}"; line="${line//[[:space:]]/}"
  [[ -n "$line" ]] && ROSTER+=("$line")
done < apps.txt

# which apps actually ship a stop.sh (sill is a library — none)
typeset -a STOPPABLE
for app in $ROSTER; do
  [[ -f "$app/stop.sh" ]] && STOPPABLE+=("$app")
done

if [[ "${1:-}" == "--list" || "${1:-}" == "-l" ]]; then
  for app in $STOPPABLE; do echo "$app"; done
  exit 0
fi

stop_one() {
  local app="$1"
  if [[ ! -f "$app/stop.sh" ]]; then
    echo "stop.sh: '$app' has no stop.sh" >&2; return 2
  fi
  echo "■ $app"
  ( cd "$app" && ./stop.sh ) || true   # app stop.sh may exit 1 on survivors
}

if [[ $# -eq 0 ]]; then
  for app in $STOPPABLE; do stop_one "$app"; done
  echo "✔ stop.sh done (${#STOPPABLE} app(s))."
else
  stop_one "$1"
fi
