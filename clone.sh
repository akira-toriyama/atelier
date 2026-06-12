#!/bin/zsh
# Fetch every atelier app into the ghq tree via `ghq get`.
# Idempotent: repos already present are skipped (or `git remote update`d with -u).
#
#   ./clone.sh            ghq get any missing apps (SSH)
#   ./clone.sh --update   also update apps already present (ghq get -u)
#   ./clone.sh --https    fetch via HTTPS instead of SSH (default: SSH)
#
# Roster lives in ./apps.txt; owner defaults to akira-toriyama (GH_OWNER=...).
# Apps land in $(ghq root)/github.com/<owner>/<app> — never inside atelier.
set -e
cd "$(dirname "$0")"
source ./lib.sh

PROTO="ssh"
UPDATE=0
for arg in "$@"; do
  case "$arg" in
    --update) UPDATE=1 ;;
    --https)  PROTO="https" ;;
    --ssh)    PROTO="ssh" ;;
    -h|--help) sed -n '2,10p' "$0"; exit 0 ;;
    *) echo "clone.sh: unknown arg '$arg'" >&2; exit 2 ;;
  esac
done

load_roster

typeset -a FLAGS
[[ "$PROTO" == "ssh" ]] && FLAGS+=(-p)   # ghq get -p clones via SSH
(( UPDATE )) && FLAGS+=(-u)

flagstr="${(j: :)FLAGS}"
for app in $ROSTER; do
  if app_cloned "$app" && (( ! UPDATE )); then
    echo "✓ $app — already present"
  else
    echo "⬇ $app — ghq get ${flagstr:+$flagstr }$OWNER/$app"
    ghq get $FLAGS "$OWNER/$app"
  fi
done
echo "✔ clone.sh done (${#ROSTER} app(s) under $GHQ_ROOT/github.com/$OWNER/)."
