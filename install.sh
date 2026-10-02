#!/data/data/com.termux/files/usr/bin/bash
# termux-forge — one-line installer
#
#   curl -fsSL https://raw.githubusercontent.com/Mahesh953-hub/termux-forge/main/install.sh | bash
#
# Downloads termux-forge into ~/.local/share/termux-forge and symlinks it into
# $PREFIX/bin as `tf`. Idempotent: re-running updates an existing checkout.
set -euo pipefail

REPO="${TF_REPO:-Mahesh953-hub/termux-forge}"
BRANCH="${TF_BRANCH:-main}"
URL="https://raw.githubusercontent.com/$REPO/$BRANCH/termux-forge"
DEST="${TF_DIR:-$HOME/.local/share/termux-forge}"
BIN="${PREFIX:-$HOME/.local/bin}/tf"

say()  { printf '\033[38;5;114m▚\033[0m %s\n' "$*"; }
warn() { printf '\033[38;5;221m▚\033[0m %s\n' "$*" >&2; }
die()  { printf '\033[38;5;203m✗ %s\033[0m\n' "$*" >&2; exit 1; }

[ -n "${PREFIX:-}" ] || die "not running inside Termux (PREFIX is unset)"

say "TERMUX FORGE installer"
say "  repo   $REPO@$BRANCH"
say "  dest   $DEST"
echo

command -v curl >/dev/null 2>&1 || die "curl is missing: pkg install curl"

mkdir -p "$DEST"
say "downloading termux-forge…"
curl -fsSL "$URL" -o "$DEST/termux-forge.tmp" || die "download failed: $URL"
mv -f "$DEST/termux-forge.tmp" "$DEST/termux-forge"

# helper commands live next to the script; fetch them too or the UI is broken
mkdir -p "$DEST/commands" "$DEST/assets"
missing=""
# must match the list step_commands installs — a short list here means
# `tf --only commands` silently installs nothing for the missing ones
for f in tfart tf-style-preview tfloop tf-prompt-preview tf-theme-preview \
         tf-keys-preview tf-font-preview reveal setname ftext findbig peek scrub; do
  if curl -fsSL "https://raw.githubusercontent.com/$REPO/$BRANCH/commands/$f" \
       -o "$DEST/commands/$f" 2>/dev/null; then
    chmod +x "$DEST/commands/$f"
  else
    missing+="$f "
  fi
done
if [ -n "$missing" ]; then
  warn "could not fetch: $missing"
  warn "run inside a full clone instead:  git clone $REPO"
fi
[ -f "$DEST/tf-style-preview.sh" ] || \
  curl -fsSL "https://raw.githubusercontent.com/$REPO/$BRANCH/tf-style-preview.sh" \
    -o "$DEST/tf-style-preview.sh" 2>/dev/null || \
  missing="$missing tf-style-preview.sh"
curl -fsSL "https://raw.githubusercontent.com/$REPO/$BRANCH/assets/logo.txt" \
  -o "$DEST/assets/logo.txt" 2>/dev/null || true

bash -n "$DEST/termux-forge" || die "downloaded script failed bash -n"
chmod +x "$DEST/termux-forge"

mkdir -p "$(dirname "$BIN")"
ln -sf "$DEST/termux-forge" "$BIN"
say "installed → $BIN"
echo
say "run:  tf"
say "     tf --dry-run     see what it would do"
say "     tf --list        list every step"