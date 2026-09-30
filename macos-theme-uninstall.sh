#!/usr/bin/env bash

set -e

echo "=========================================="
echo " macOS-style Linux Mint Uninstaller"
echo "=========================================="

echo
echo "[1/7] Stopping Plank..."

pkill plank 2>/dev/null || true

echo
echo "[2/7] Removing Plank autostart..."

rm -f "$HOME/.config/autostart/plank.desktop"

echo
echo "[3/7] Removing Plank configuration..."

rm -rf "$HOME/.config/plank"

echo
echo "[4/7] Removing WhiteSur GTK theme..."

rm -rf "$HOME/.themes/WhiteSur-Light"
rm -rf "$HOME/.themes/WhiteSur-Dark"
rm -rf "$HOME/.themes/WhiteSur"

echo
echo "[5/7] Removing WhiteSur icon theme..."

rm -rf "$HOME/.icons/WhiteSur"
rm -rf "$HOME/.icons/WhiteSur-dark"
rm -rf "$HOME/.icons/WhiteSur-light"

echo
echo "[6/7] Restoring Linux Mint Cinnamon defaults..."

# Restore Cinnamon theme
gsettings set org.cinnamon.theme name "Mint-Y"

# Restore GTK theme
gsettings set org.cinnamon.desktop.interface gtk-theme "Mint-Y"

# Restore icon theme
gsettings set org.cinnamon.desktop.interface icon-theme "Mint-Y"

# Restore cursor
gsettings set org.cinnamon.desktop.interface cursor-theme "DMZ-White"

# Restore default Cinnamon font
gsettings set org.cinnamon.desktop.interface font-name "Noto Sans 10"

# Restore default window title font
gsettings set org.cinnamon.desktop.wm.preferences titlebar-font "Noto Sans Bold 10"

echo
echo "[7/7] Removing downloaded temporary files..."

rm -rf /tmp/WhiteSur-gtk-theme
rm -rf /tmp/WhiteSur-icon-theme

echo
echo "=========================================="
echo " macOS customization removed"
echo "=========================================="

echo
echo "The following were restored:"
echo "  ✓ Cinnamon theme"
echo "  ✓ GTK theme"
echo "  ✓ Icon theme"
echo "  ✓ Cursor"
echo "  ✓ Fonts"
echo "  ✓ Plank autostart"
echo "  ✓ Plank configuration"
echo
echo "NOTE:"
echo "The Plank package itself was NOT removed."
echo "If you want to remove Plank completely, run:"
echo
echo "    sudo apt remove --purge plank"
echo
echo "Please log out and log back in."
echo
