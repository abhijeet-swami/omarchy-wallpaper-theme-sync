#!/usr/bin/env sh
set -e

WALLPAPER="$1"
if [ -z "$WALLPAPER" ]; then
  echo "Usage: $0 <path-to-wallpaper>"
  exit 1
fi

if [ ! -f "$WALLPAPER" ]; then
  echo "Error: wallpaper not found: $WALLPAPER"
  exit 1
fi

WALLPAPER_REAL="$(realpath "$WALLPAPER")"
CURRENT_BG="$HOME/.config/omarchy/current/background"

if [ -L "$CURRENT_BG" ] || [ -f "$CURRENT_BG" ]; then
  CURRENT_BG_REAL="$(realpath "$CURRENT_BG")"
  if [ "$CURRENT_BG_REAL" = "$WALLPAPER_REAL" ]; then
    exit 0
  fi
fi

THEME_DIR="$HOME/.config/omarchy/themes/dynamic"
BG_DIR="$THEME_DIR/backgrounds"
LINK_PATH="$BG_DIR/dynamic_wallpaper"

rm -rf "$THEME_DIR"
mkdir -p "$BG_DIR"
ln -sf "$WALLPAPER_REAL" "$LINK_PATH"
wallust run "$WALLPAPER_REAL"
bash ~/.config/bin/create_files.sh
