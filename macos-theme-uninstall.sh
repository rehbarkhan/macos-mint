#!/usr/bin/env bash

set -euo pipefail

# ============================================================
# macOS-style Linux Mint Cinnamon Uninstaller
# ============================================================

BACKUP_DIR="$HOME/.macos-mint-backup"

GTK_DIR="$HOME/.macos-mint-WhiteSur-gtk"
ICON_DIR="$HOME/.macos-mint-WhiteSur-icons"

echo
echo "============================================================"
echo " macOS-style Linux Mint Uninstaller"
echo "============================================================"
echo

# ------------------------------------------------------------
# Stop Plank
# ------------------------------------------------------------

echo "[1/8] Stopping Plank..."

pkill plank 2>/dev/null || true

# ------------------------------------------------------------
# Remove Plank autostart
# ------------------------------------------------------------

echo
echo "[2/8] Removing Plank autostart..."

rm -f \
    "$HOME/.config/autostart/plank.desktop"

# ------------------------------------------------------------
# Remove Plank configuration created by this setup
# ------------------------------------------------------------

echo
echo "[3/8] Removing Plank configuration..."

rm -rf \
    "$HOME/.config/plank"

# ------------------------------------------------------------
# Remove WhiteSur GTK themes using official installer
# ------------------------------------------------------------

echo
echo "[4/8] Removing WhiteSur GTK theme..."

if [[ -x "$GTK_DIR/install.sh" ]]; then
    cd "$GTK_DIR"

    ./install.sh -r || true
else
    echo "WhiteSur GTK installer not found."
    echo "Removing known user theme directories..."

    rm -rf "$HOME/.themes/WhiteSur"
    rm -rf "$HOME/.themes/WhiteSur-Light"
    rm -rf "$HOME/.themes/WhiteSur-Dark"
fi

# ------------------------------------------------------------
# Remove WhiteSur icons using official installer
# ------------------------------------------------------------

echo
echo "[5/8] Removing WhiteSur icons..."

if [[ -x "$ICON_DIR/install.sh" ]]; then
    cd "$ICON_DIR"

    ./install.sh -r || true
else
    echo "WhiteSur icon installer not found."
    echo "Removing known WhiteSur icon directories..."

    rm -rf "$HOME/.local/share/icons/WhiteSur"
    rm -rf "$HOME/.local/share/icons/WhiteSur-light"
    rm -rf "$HOME/.local/share/icons/WhiteSur-dark"

    rm -rf "$HOME/.icons/WhiteSur"
    rm -rf "$HOME/.icons/WhiteSur-light"
    rm -rf "$HOME/.icons/WhiteSur-dark"
fi

# ------------------------------------------------------------
# Restore Cinnamon settings
# ------------------------------------------------------------

echo
echo "[6/8] Restoring Cinnamon settings..."

restore_gsetting() {

    local schema="$1"
    local key="$2"
    local file="$3"

    if [[ -f "$file" ]]; then

        local value

        value="$(cat "$file")"

        if [[ -n "$value" ]]; then

            echo "Restoring $schema $key"

            gsettings set "$schema" "$key" "$value" \
                2>/dev/null || true

        fi

    fi
}

if [[ -d "$BACKUP_DIR" ]]; then

    restore_gsetting \
        "org.cinnamon.theme" \
        "name" \
        "$BACKUP_DIR/cinnamon-theme.txt"

    restore_gsetting \
        "org.cinnamon.desktop.interface" \
        "gtk-theme" \
        "$BACKUP_DIR/gtk-theme.txt"

    restore_gsetting \
        "org.cinnamon.desktop.interface" \
        "icon-theme" \
        "$BACKUP_DIR/icon-theme.txt"

    restore_gsetting \
        "org.cinnamon.desktop.interface" \
        "cursor-theme" \
        "$BACKUP_DIR/cursor-theme.txt"

    restore_gsetting \
        "org.cinnamon.desktop.interface" \
        "font-name" \
        "$BACKUP_DIR/font-name.txt"

    restore_gsetting \
        "org.cinnamon.desktop.wm.preferences" \
        "titlebar-font" \
        "$BACKUP_DIR/titlebar-font.txt"

    restore_gsetting \
        "org.cinnamon.desktop.wm.preferences" \
        "button-layout" \
        "$BACKUP_DIR/button-layout.txt"

else

    echo
    echo "No backup found."
    echo "Using safe Linux Mint defaults."

    gsettings set \
        org.cinnamon.theme \
        name \
        "Mint-Y" || true

    gsettings set \
        org.cinnamon.desktop.interface \
        gtk-theme \
        "Mint-Y" || true

    gsettings set \
        org.cinnamon.desktop.interface \
        icon-theme \
        "Mint-Y" || true

    gsettings set \
        org.cinnamon.desktop.interface \
        cursor-theme \
        "DMZ-White" || true

    gsettings set \
        org.cinnamon.desktop.interface \
        font-name \
        "Noto Sans 10" || true

    gsettings set \
        org.cinnamon.desktop.wm.preferences \
        titlebar-font \
        "Noto Sans Bold 10" || true

    gsettings set \
        org.cinnamon.desktop.wm.preferences \
        button-layout \
        ":minimize,maximize,close" || true

fi

# ------------------------------------------------------------
# Remove downloaded repositories
# ------------------------------------------------------------

echo
echo "[7/8] Removing downloaded theme repositories..."

rm -rf "$GTK_DIR"
rm -rf "$ICON_DIR"

# ------------------------------------------------------------
# Refresh icon cache
# ------------------------------------------------------------

echo
echo "[8/8] Refreshing icon cache..."

gtk-update-icon-cache \
    "$HOME/.local/share/icons/WhiteSur" \
    >/dev/null 2>&1 || true

echo
echo "============================================================"
echo " macOS customization removed"
echo "============================================================"
echo
echo "Plank has been disabled."
echo
echo "WhiteSur GTK theme removed."
echo "WhiteSur icons removed."
echo "Cinnamon settings restored."
echo
echo "The backup has been kept here:"
echo
echo "  $BACKUP_DIR"
echo
echo "The Plank package itself has NOT been removed."
echo
echo "If you want to completely remove Plank:"
echo
echo "  sudo apt remove --purge plank"
echo "  sudo apt autoremove"
echo
echo "Please log out and log back in."
echo
