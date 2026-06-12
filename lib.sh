# lib.sh — shared helpers for atelier orchestration (sourced by clone/run/stop/pull).
#
# Apps live in the ghq tree: $(ghq root)/github.com/<owner>/<app>.
# atelier only orchestrates — it never vendors app sources in-tree.
#
# Provides: $OWNER, $GHQ_ROOT, app_dir(), app_cloned(), load_roster()/$ROSTER.
#
# Assumes a single (primary) ghq root — app_dir() builds the canonical path
# rather than querying `ghq list` per app (which walks the whole root and is
# noisy). For multi-root setups, point GH_OWNER/ghq.root at the intended root.

OWNER="${GH_OWNER:-akira-toriyama}"

if ! command -v ghq >/dev/null 2>&1; then
  echo "atelier: ghq not found — install it (\`brew install ghq\`) and set ghq.root." >&2
  exit 1
fi
GHQ_ROOT="$(ghq root 2>/dev/null | head -1)"
if [[ -z "$GHQ_ROOT" ]]; then
  echo "atelier: could not determine ghq root (\`ghq root\`)." >&2
  exit 1
fi

# Absolute path to an app's ghq checkout (whether or not it exists yet).
# Deterministic — matches where `ghq get <owner>/<app>` clones.
app_dir() { print -- "$GHQ_ROOT/github.com/$OWNER/$1" }

# Is the app cloned in the ghq tree?
app_cloned() { [[ -d "$(app_dir "$1")/.git" ]] }

# Load apps.txt roster (strip comments / blanks) into the $ROSTER array.
typeset -ga ROSTER
load_roster() {
  ROSTER=()
  local line
  while IFS= read -r line; do
    line="${line%%#*}"; line="${line//[[:space:]]/}"
    [[ -n "$line" ]] && ROSTER+=("$line")
  done < apps.txt
}
