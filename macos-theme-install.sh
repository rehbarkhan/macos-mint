#!/usr/bin/env bash

set -euo pipefail

# ============================================================
# macOS-style Linux Mint Cinnamon Setup
# Tested conceptually for Linux Mint 22.x / Cinnamon
#
# Components:
#   - WhiteSur GTK theme
#   - WhiteSur Cinnamon theme files
#   - WhiteSur icons
#   - Plank dock
#   - Inter font
#
# IMPORTANT:
#   Cinnamon desktop theme remains Mint-Y.
#   This avoids the black/broken Cinnamon menu issue.
# ============================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

BACKUP_DIR="$HOME/.macos-mint-backup"

GTK_REPO="https://github.com/vinceliuice/WhiteSur-gtk-theme.git"
ICON_REPO="https://github.com/vinceliuice/WhiteSur-icon-theme.git"

GTK_DIR="$HOME/.macos-mint-WhiteSur-gtk"
ICON_DIR="$HOME/.macos-mint-WhiteSur-icons"

echo
echo "============================================================"
echo " macOS-style Linux Mint Cinnamon Installer"
echo "============================================================"
echo

# ------------------------------------------------------------
# Check Cinnamon
# ------------------------------------------------------------

if ! command -v cinnamon-session >/dev/null 2>&1; then
    echo "ERROR: Cinnamon does not appear to be installed."
    echo
    exit 1
fi

# ------------------------------------------------------------
# Backup existing settings
# ------------------------------------------------------------

echo "[1/10] Creating backup..."

mkdir -p "$BACKUP_DIR"

gsettings get org.cinnamon.theme name \
    > "$BACKUP_DIR/cinnamon-theme.txt" 2>/dev/null || true

gsettings get org.cinnamon.desktop.interface gtk-theme \
    > "$BACKUP_DIR/gtk-theme.txt" 2>/dev/null || true

gsettings get org.cinnamon.desktop.interface icon-theme \
    > "$BACKUP_DIR/icon-theme.txt" 2>/dev/null || true

gsettings get org.cinnamon.desktop.interface cursor-theme \
    > "$BACKUP_DIR/cursor-theme.txt" 2>/dev/null || true

gsettings get org.cinnamon.desktop.interface font-name \
    > "$BACKUP_DIR/font-name.txt" 2>/dev/null || true

gsettings get org.cinnamon.desktop.wm.preferences titlebar-font \
    > "$BACKUP_DIR/titlebar-font.txt" 2>/dev/null || true

gsettings get org.cinnamon.desktop.wm.preferences button-layout \
    > "$BACKUP_DIR/button-layout.txt" 2>/dev/null || true

echo "Backup saved to:"
echo "$BACKUP_DIR"

# ------------------------------------------------------------
# Install dependencies
# ------------------------------------------------------------

echo
echo "[2/10] Installing required packages..."

sudo apt update

sudo apt install -y \
    git \
    plank \
    fonts-inter \
    sassc \
    libglib2.0-dev-bin \
    libxml2-utils

# ------------------------------------------------------------
# Stop Plank
# ------------------------------------------------------------

echo
echo "[3/10] Stopping Plank..."

pkill plank 2>/dev/null || true

# Remove the BAD launcher configuration created by
# the previous script.
#
# This is intentional.
# We do NOT create .dockitem files.
# Applications should be added to Plank normally.
# ------------------------------------------------------------

echo
echo "[4/10] Cleaning old Plank launcher configuration..."

rm -rf "$HOME/.config/plank/dock1/launchers"

# ------------------------------------------------------------
# Download WhiteSur GTK theme
# ------------------------------------------------------------

echo
echo "[5/10] Downloading WhiteSur GTK theme..."

rm -rf "$GTK_DIR"

git clone \
    --depth=1 \
    "$GTK_REPO" \
    "$GTK_DIR"

cd "$GTK_DIR"

# Install:
#   light theme
#   blue/default accent
#
# WhiteSur's installer installs the Cinnamon and Plank
# theme components as part of the theme pack.

./install.sh \
    -c light \
    -t default

# ------------------------------------------------------------
# Download WhiteSur icons
# ------------------------------------------------------------

echo
echo "[6/10] Downloading WhiteSur icons..."

rm -rf "$ICON_DIR"

git clone \
    --depth=1 \
    "$ICON_REPO" \
    "$ICON_DIR"

cd "$ICON_DIR"

# Install the normal WhiteSur icon theme.
#
# --alternative gives more macOS-like application icons.
./install.sh \
    -a

# ------------------------------------------------------------
# Configure Cinnamon
# ------------------------------------------------------------

echo
echo "[7/10] Configuring Cinnamon..."

# IMPORTANT:
#
# Keep Cinnamon desktop theme as Mint-Y.
#
# DO NOT:
#   gsettings set org.cinnamon.theme name "WhiteSur-Light"
#
# That can cause the Cinnamon menu/panel to render incorrectly.
#
gsettings set org.cinnamon.theme name "Mint-Y"

# GTK applications use WhiteSur.
gsettings set \
    org.cinnamon.desktop.interface \
    gtk-theme \
    "WhiteSur-Light"

# WhiteSur icons.
#
# Depending on the exact icon installer version,
# WhiteSur may be installed under:
#   WhiteSur
#
gsettings set \
    org.cinnamon.desktop.interface \
    icon-theme \
    "WhiteSur"

# Keep standard cursor.
gsettings set \
    org.cinnamon.desktop.interface \
    cursor-theme \
    "Adwaita"

# macOS-like font.
gsettings set \
    org.cinnamon.desktop.interface \
    font-name \
    "Inter 10"

gsettings set \
    org.cinnamon.desktop.wm.preferences \
    titlebar-font \
    "Inter Bold 10"

# ------------------------------------------------------------
# macOS-style window buttons
# ------------------------------------------------------------

echo
echo "[8/10] Configuring macOS-style window buttons..."

# macOS normally has:
#
#   Close / Minimize / Maximize
#
# on the LEFT side of the title bar.

gsettings set \
    org.cinnamon.desktop.wm.preferences \
    button-layout \
    "close,minimize,maximize:"

# ------------------------------------------------------------
# Configure Plank
# ------------------------------------------------------------

echo
echo "[9/10] Configuring Plank..."

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

# ------------------------------------------------------------
# Start Plank
# ------------------------------------------------------------

echo
echo "[10/10] Starting Plank..."

pkill plank 2>/dev/null || true

nohup plank >/dev/null 2>&1 &

# ------------------------------------------------------------
# Finished
# ------------------------------------------------------------

echo
echo "============================================================"
echo " Installation completed"
echo "============================================================"
echo
echo "Theme configuration:"
echo
echo "  Applications : WhiteSur-Light"
echo "  Icons        : WhiteSur"
echo "  Desktop      : Mint-Y"
echo "  Cursor       : Adwaita"
echo "  Font         : Inter"
echo "  Dock         : Plank"
echo
echo "============================================================"
echo
echo "IMPORTANT:"
echo
echo "1. Log out and log back in."
echo
echo "2. Plank will start automatically."
echo
echo "3. Do NOT manually create .dockitem files."
echo
echo "4. To add applications to Plank:"
echo "      Start the application"
echo "      Right-click its Plank icon"
echo "      Select 'Keep in Dock'"
echo
echo "5. Open Plank Preferences to adjust:"
echo "      Position : Bottom"
echo "      Icon Size: 48-56"
echo "      Zoom     : ON"
echo
echo "Backup:"
echo "  $BACKUP_DIR"
echo
echo "To uninstall:"
echo "  ./macos-mint-uninstall.sh"
echo
