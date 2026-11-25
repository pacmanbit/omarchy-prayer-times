#!/usr/bin/env bash
set -euo pipefail

if command -v omarchy >/dev/null 2>&1; then
  omarchy plugin disable pacmanbit.prayer-times >/dev/null 2>&1 || true
fi

rm -rf "$HOME/.config/omarchy/plugins/pacmanbit.prayer-times"
rm -f "$HOME/.local/bin/prayer-times"

echo "Removed pacmanbit.prayer-times plugin and ~/.local/bin/prayer-times."
echo "User config ~/.config/prayer-times.json was preserved (delete manually if desired)."
