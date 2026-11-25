#!/usr/bin/env bash
# Installer for Islamic Prayer Times bar widget & CLI

set -euo pipefail

REPO_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
MODE=""
CITY="Al-Karak"
COUNTRY="Jordan"
METHOD="JORDAN"
NON_INTERACTIVE=0

usage() {
  cat <<EOF
Usage: ./install.sh [OPTIONS]

Targets (pick one or run interactively):
  --omarchy-plugin   Install as a native Omarchy 4.0 QML bar plugin (~/.config/omarchy/plugins/pacmanbit.prayer-times)
  --waybar           Install standalone CLI script to ~/.local/bin/prayer-times (for Waybar / Polybar / CLI)
  --all              Install both Omarchy plugin and ~/.local/bin/prayer-times

Options:
  --city CITY        City name (default: Al-Karak)
  --country COUNTRY  Country name (default: Jordan)
  --method METHOD    AlAdhan calculation method (default: JORDAN)
  -y, --yes          Non-interactive mode
  -h, --help         Show this help
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --omarchy-plugin) MODE="omarchy"; shift ;;
    --waybar|--cli) MODE="waybar"; shift ;;
    --all) MODE="all"; shift ;;
    --city) CITY="${2:-}"; shift 2 ;;
    --country) COUNTRY="${2:-}"; shift 2 ;;
    --method) METHOD="${2:-}"; shift 2 ;;
    -y|--yes) NON_INTERACTIVE=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage; exit 1 ;;
  esac
done

info() { printf "\033[1;34m[install]\033[0m %s\n" "$*"; }
ok()   { printf "\033[1;32m[ok]\033[0m      %s\n" "$*"; }

if [[ -z "$MODE" ]]; then
  if (( NON_INTERACTIVE )); then
    if [[ -d "$HOME/.config/omarchy" ]]; then MODE="omarchy"; else MODE="waybar"; fi
  else
    echo "=========================================="
    echo "  Islamic Prayer Times Widget Installer"
    echo "=========================================="
    echo "  1) Omarchy 4.0 Native Bar Plugin (QML)"
    echo "  2) Waybar / Polybar / Standalone CLI (~/.local/bin/prayer-times)"
    echo "  3) Both"
    read -r -p "Choose target [1/2/3]: " ch || true
    case "$ch" in
      1) MODE="omarchy" ;;
      2) MODE="waybar" ;;
      3) MODE="all" ;;
      *) MODE="waybar" ;;
    esac

    read -r -p "City [$CITY]: " in_city || true
    [[ -n "$in_city" ]] && CITY="$in_city"
    read -r -p "Country [$COUNTRY]: " in_country || true
    [[ -n "$in_country" ]] && COUNTRY="$in_country"
    read -r -p "AlAdhan Method (JORDAN, MWL, ISNA, MAKKAH, EGYPT, ...) [$METHOD]: " in_method || true
    [[ -n "$in_method" ]] && METHOD="$in_method"
  fi
fi

# Write user config
mkdir -p "$HOME/.config"
cat > "$HOME/.config/prayer-times.json" <<EOF
{
  "city": "$CITY",
  "country": "$COUNTRY",
  "method": "$METHOD",
  "now_window": 20,
  "close_threshold": 30,
  "now_color": "#50FA7B",
  "close_color": "#FAB387"
}
EOF
ok "Saved config to ~/.config/prayer-times.json ($CITY, $COUNTRY, method=$METHOD)"

if [[ "$MODE" == "omarchy" || "$MODE" == "all" ]]; then
  PLUGIN_DIR="$HOME/.config/omarchy/plugins/pacmanbit.prayer-times"
  mkdir -p "$PLUGIN_DIR/scripts"
  cp -a "$REPO_DIR/manifest.json" "$REPO_DIR/BarWidget.qml" "$PLUGIN_DIR/"
  cp -a "$REPO_DIR/scripts/prayer-times" "$PLUGIN_DIR/scripts/"
  chmod +x "$PLUGIN_DIR/scripts/prayer-times"
  ok "Installed Omarchy plugin to $PLUGIN_DIR"

  if command -v omarchy >/dev/null 2>&1; then
    omarchy-shell shell rescanPlugins >/dev/null 2>&1 || true
    omarchy plugin enable pacmanbit.prayer-times >/dev/null 2>&1 || true
    ok "Enabled plugin pacmanbit.prayer-times in Omarchy shell."
  else
    info "Restart Omarchy shell or run: omarchy plugin enable pacmanbit.prayer-times"
  fi
fi

if [[ "$MODE" == "waybar" || "$MODE" == "all" ]]; then
  mkdir -p "$HOME/.local/bin"
  cp -a "$REPO_DIR/scripts/prayer-times" "$HOME/.local/bin/prayer-times"
  chmod +x "$HOME/.local/bin/prayer-times"
  ok "Installed CLI to ~/.local/bin/prayer-times"
  info "See waybar/config.jsonc and waybar/style.css for Waybar integration."
fi
