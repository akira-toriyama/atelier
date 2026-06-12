#!/bin/sh
# atelier bootstrap — clone the workspace repo and all its apps in one step.
#
# Git has no post-clone hook (and hooks aren't transferred by clone), so a
# bare `git clone` can't auto-run anything. This is the supported one-step:
# it clones atelier, then runs the repo's own ./clone.sh to fetch every app.
#
#   # one-liner (clone atelier → clone every app)
#   curl -fsSL https://raw.githubusercontent.com/akira-toriyama/atelier/main/install.sh | sh
#
#   # already inside an atelier checkout
#   ./install.sh
#
# Env overrides:
#   ATELIER_DIR=path        where to clone atelier   (default: ./atelier)
#   GH_OWNER=name           GitHub owner             (default: akira-toriyama)
#   ATELIER_PROTO=https|ssh  remote protocol         (default: ssh)
#
# Extra args are forwarded to clone.sh (e.g. `... | sh -s -- --update`).
set -e

OWNER="${GH_OWNER:-akira-toriyama}"
PROTO="${ATELIER_PROTO:-ssh}"
DIR="${ATELIER_DIR:-atelier}"

atelier_remote() {
  if [ "$PROTO" = "https" ]; then
    echo "https://github.com/$OWNER/atelier.git"
  else
    echo "git@github.com:$OWNER/atelier.git"
  fi
}

run_clone() {
  # clone.sh is zsh; invoke zsh explicitly so this works even when piped to sh.
  [ "$PROTO" = "https" ] && set -- --https "$@"
  echo "▶ ./clone.sh $*"
  exec zsh ./clone.sh "$@"
}

# Already inside an atelier checkout (has clone.sh + apps.txt)? Just run it.
if [ -f clone.sh ] && [ -f apps.txt ]; then
  echo "✓ atelier checkout detected here — fetching apps"
  run_clone "$@"
fi

# Otherwise clone atelier first, then run its clone.sh.
if [ -d "$DIR/.git" ]; then
  echo "✓ $DIR already cloned — git pull --ff-only"
  git -C "$DIR" pull --ff-only
else
  echo "⬇ cloning atelier → $DIR ($(atelier_remote))"
  git clone "$(atelier_remote)" "$DIR"
fi

cd "$DIR"
run_clone "$@"
