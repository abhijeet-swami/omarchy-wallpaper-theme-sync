# Wallpaper Menu Setup (Hyprland + Elephant)

This repository provides an Elephant-based wallpaper menu for Hyprland, powered by Wallust for dynamic color generation.

---

## Automatic Installation

Follow these steps exactly, from cloning the repository to running the installer.

### Full installation steps

```bash
git clone https://github.com/abhijeet-swami/omarchy-wallpaper-theme-sync
cd omarchy-wallpaper-theme-sync
chmod +x install.sh
./install.sh
```

What the script does:
- Creates `~/Wallpapers` (all wallpapers placed here will appear in the menu)
- Copies required configuration files into `~/.config`
- Installs the required package (`wallust`)
- Adds the Hyprland keybinding if it does not already exist
- Makes all files inside `~/.config/bin` executable

Reload Hyprland after installation.

---

## Manual Installation

Use this method only if you do not want to run the script.

### Step 1: Copy configuration files

```bash
cp -r bin ~/.config
cp -r wallust ~/.config
cp wallpaper-selector.lua ~/.config/elephant/menus
```

### Step 2: Create wallpapers directory

```bash
mkdir -p ~/Wallpapers
```

All wallpapers placed inside this directory will be shown in the menu.

### Step 3: Edit Hyprland keybindings

```bash
nvim ~/.config/hypr/bindings.conf
```

Add the following line:

```ini
bind = SUPER SHIFT ALT, P, exec, elephant menu wallpapers
```

### Step 4: Install required packages

```bash
yay -S wallust
```

---

## Usage

Reload Hyprland and press:

```text
Super + Shift + Alt + P
```

The wallpaper menu will open and apply wallpapers using Wallust-based color theming.
