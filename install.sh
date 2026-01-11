#!/usr/bin/env bash

set -e

echo "==> Starting wallpaper menu installation"

CONFIG_DIR="$HOME/.config"

mkdir -p "$CONFIG_DIR/elephant/menus"
mkdir -p "$HOME/Wallpapers"

echo "==> Copying bin folder"
cp -r ./bin "$CONFIG_DIR"

echo "==> Making bin files executable"
chmod +x "$CONFIG_DIR/bin"/*

echo "==> Copying wallust config"
cp -r ./wallust "$CONFIG_DIR"

echo "==> Installing Elephant wallpaper menu"
cp ./wallpaper-selector.lua "$CONFIG_DIR/elephant/menus"

if ! command -v yay &> /dev/null; then
  echo "✗ yay not found. Please install yay first."
  exit 1
fi

echo "==> Installing required packages"
yay -S --needed wallust

HYPR_BINDINGS="$CONFIG_DIR/hypr/bindings.conf"
BIND_LINE="bind = SUPER SHIFT ALT, P, exec, ~/.config/bin/launch.sh"

echo "==> Configuring Hyprland keybinding"
if [ -f "$HYPR_BINDINGS" ]; then
  if ! grep -Fxq "$BIND_LINE" "$HYPR_BINDINGS"; then
    echo "$BIND_LINE" >> "$HYPR_BINDINGS"
    echo "✓ Keybinding added"
  else
    echo "✓ Keybinding already exists"
  fi
else
  echo "✗ Hyprland bindings.conf not found at $HYPR_BINDINGS"
fi

echo "==> Installation complete"
echo "Place your wallpapers inside ~/Wallpapers and reload Hyprland"
