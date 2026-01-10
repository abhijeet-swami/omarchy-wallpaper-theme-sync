#!/usr/bin/env sh

set -e

THEME_DIR="$HOME/.config/omarchy/current/theme/"

FILES="
hyprland.conf
hyprlock.conf
walker.css
waybar.css
swayosd.css
kitty.conf
"

for file in $FILES; do
  FILE_PATH="$THEME_DIR/$file"

  if [ -f "$FILE_PATH" ]; then
    bash ~/.config/bin/remove_colors.sh "$FILE_PATH"
  fi
done

omarchy-theme-set dynamic
