#!/usr/bin/env bash

set -e

echo "=========================================="
echo " macOS-style Linux Mint Cinnamon Setup"
echo " Linux Mint 22.3 Zena"
echo "=========================================="

if [[ "$XDG_CURRENT_DESKTOP" != *"X-Cinnamon"* && "$XDG_CURRENT_DESKTOP" != *"Cinnamon"* ]]; then
    echo "WARNING: This script is designed for Cinnamon."
    echo "Detected desktop: ${XDG_CURRENT_DESKTOP:-unknown}"
    read -rp "Continue anyway? [y/N]: " answer
    [[ "$answer" =~ ^[Yy]$ ]] || exit 1
fi

echo
echo "[1/8] Updating package information..."
sudo apt update

echo
echo "[2/8] Installing required packages..."

sudo apt install -y \
    git \
    curl \
    wget \
    unzip \
    plank \
    fonts-inter \
    fonts-noto \
    gnome-themes-extra \
    gtk2-engines-murrine \
    sassc \
    papirus-icon-theme

echo
echo "[3/8] Creating theme directories..."

mkdir -p "$HOME/.themes"
mkdir -p "$HOME/.icons"
mkdir -p "$HOME/.local/share/themes"
mkdir -p "$HOME/.local/share/icons"

echo
echo "[4/8] Installing WhiteSur GTK theme..."

TMP_DIR="$(mktemp -d)"

git clone --depth=1 \
    https://github.com/vinceliuice/WhiteSur-gtk-theme.git \
    "$TMP_DIR/WhiteSur-gtk-theme"

cd "$TMP_DIR/WhiteSur-gtk-theme"

./install.sh \
    -d "$HOME/.themes" \
    -c light \
    -t default

echo
echo "[5/8] Installing WhiteSur icon theme..."

cd "$TMP_DIR"

git clone --depth=1 \
    https://github.com/vinceliuice/WhiteSur-icon-theme.git \
    WhiteSur-icon-theme

cd WhiteSur-icon-theme

./install.sh \
    -d "$HOME/.icons"

echo
echo "[6/8] Configuring Cinnamon appearance..."

# GTK theme
gsettings set org.cinnamon.desktop.interface gtk-theme "WhiteSur-Light"

# Cinnamon theme
gsettings set org.cinnamon.theme name "WhiteSur-Light"

# Icon theme
gsettings set org.cinnamon.desktop.interface icon-theme "WhiteSur"

# Cursor
gsettings set org.cinnamon.desktop.interface cursor-theme "Adwaita"

# Font
gsettings set org.cinnamon.desktop.interface font-name "Inter 10"

# Window title font
gsettings set org.cinnamon.desktop.wm.preferences titlebar-font "Inter Bold 10"

echo
echo "[7/8] Configuring Plank dock..."

mkdir -p "$HOME/.config/plank/dock1/launchers"

cat > "$HOME/.config/plank/dock1/launchers/files.dockitem" <<'EOF'
[PlankItemsDockItem]
Launcher=file-manager.desktop
EOF

cat > "$HOME/.config/plank/dock1/launchers/terminal.dockitem" <<'EOF'
[PlankItemsDockItem]
Launcher=org.gnome.Terminal.desktop
EOF

cat > "$HOME/.config/plank/dock1/launchers/firefox.dockitem" <<'EOF'
[PlankItemsDockItem]
Launcher=firefox.desktop
EOF

cat > "$HOME/.config/plank/dock1/launchers/chrome.dockitem" <<'EOF'
[PlankItemsDockItem]
Launcher=google-chrome.desktop
EOF

echo
echo "[8/8] Creating startup entry for Plank..."

mkdir -p "$HOME/.config/autostart"

cat > "$HOME/.config/autostart/plank.desktop" <<'EOF'
[Desktop Entry]
Type=Application
Name=Plank
Comment=macOS-style Dock
Exec=plank
Icon=plank
Terminal=false
StartupNotify=false
X-GNOME-Autostart-enabled=true
EOF

echo
echo "=========================================="
echo " Setup completed!"
echo "=========================================="

echo
echo "Starting Plank..."

pkill plank 2>/dev/null || true
nohup plank >/dev/null 2>&1 &

echo
echo "IMPORTANT:"
echo "Log out and log back in for all Cinnamon theme changes."
echo
echo "After logging in:"
echo "  - Move Cinnamon panel to the TOP"
echo "  - Set panel height around 28-32 px"
echo "  - Hide the bottom panel if you have one"
echo "  - Plank will act as your macOS-style dock"
echo
echo "Done."
