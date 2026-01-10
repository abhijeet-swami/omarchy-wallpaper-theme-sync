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

THEME_DIR="$HOME/.config/omarchy/themes/dynamic"
BG_DIR="$THEME_DIR/backgrounds"
LINK_PATH="$BG_DIR/dynamic_wallpaper"

if [ -d "$THEME_DIR" ] && [ -L "$LINK_PATH" ]; then
  CURRENT_TARGET="$(realpath "$LINK_PATH")"

  if [ "$CURRENT_TARGET" = "$WALLPAPER_REAL" ]; then
    exit 0
  else
    rm -rf "$THEME_DIR"
  fi
fi

mkdir -p "$BG_DIR"

ln -sf "$WALLPAPER_REAL" "$LINK_PATH"

wallust run "$WALLPAPER_REAL"

bash ~/.config/bin/create_files.sh
