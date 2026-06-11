#!/bin/zsh
# Clone every atelier app from GitHub into this directory.
# Idempotent: present clones are skipped (or fast-forwarded with --update).
#
#   ./clone.sh            clone any missing apps
#   ./clone.sh --update   also `git pull --ff-only` apps already present
#   ./clone.sh --https    use HTTPS remotes instead of SSH (default: SSH)
#
# Roster lives in ./apps.txt; owner defaults to akira-toriyama
# (override with GH_OWNER=...).
set -e
cd "$(dirname "$0")"

OWNER="${GH_OWNER:-akira-toriyama}"
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

typeset -a ROSTER
while IFS= read -r line; do
  line="${line%%#*}"; line="${line//[[:space:]]/}"
  [[ -n "$line" ]] && ROSTER+=("$line")
done < apps.txt

remote_for() {
  if [[ "$PROTO" == "https" ]]; then
    print -- "https://github.com/$OWNER/$1.git"
  else
    print -- "git@github.com:$OWNER/$1.git"
  fi
}

for app in $ROSTER; do
  if [[ -d "$app/.git" ]]; then
    if (( UPDATE )); then
      echo "↻ $app — git pull --ff-only"
      git -C "$app" pull --ff-only
    else
      echo "✓ $app — already cloned"
    fi
  else
    echo "⬇ $app — cloning $(remote_for "$app")"
    git clone "$(remote_for "$app")" "$app"
  fi
done
echo "✔ clone.sh done (${#ROSTER} app(s))."
