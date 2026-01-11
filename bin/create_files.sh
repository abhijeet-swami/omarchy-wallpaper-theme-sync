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

file_list=""
for file in $FILES; do
  FILE_PATH="$THEME_DIR/$file"
  if [ -f "$FILE_PATH" ]; then
    file_list="$file_list $FILE_PATH"
  fi
done

if [ -n "$file_list" ]; then
  bash ~/.config/bin/remove_colors.sh $file_list
fi

omarchy-theme-set dynamic
