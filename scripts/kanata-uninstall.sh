#!/usr/bin/env bash
# Kanata + Karabiner Uninstall Script
# Removes all traces of Kanata and Karabiner DriverKit

set -e

echo "==============================="
echo "🗑️  Kanata Uninstall Script"
echo "==============================="
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 1. Stop and Remove Kanata Service
echo -e "${YELLOW} Stopping Kanata service...${NC}"

# Stop user-level service
if launchctl list | grep -q com.kanata.service; then
    launchctl bootout gui/$(id -u)/com.kanata.service 2>/dev/null || true
    echo "Kanata service stopped"
fi

# Remove plist
if [ -f ~/Library/LaunchAgents/com.kanata.service.plist ]; then
    rm ~/Library/LaunchAgents/com.kanata.service.plist
    echo "Removed service plist"
fi

# Kill any running kanata processes
sudo pkill kanata 2>/dev/null || true
echo "Killed any running Kanata processes"

echo ""

# 2. Remove Kanata Binary and Config
echo -e "${YELLOW}📂 Removing Kanata files...${NC}"

# Remove binary
if [ -f ~/.local/bin/kanata ]; then
    rm ~/.local/bin/kanata
    echo "Removed Kanata binary"
fi

# Ask about config
read -p "Remove Kanata config (~/.config/kanata/)? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    if [ -d ~/.config/kanata ]; then
        # Backup first
        if [ -f ~/.config/kanata/kanata.kbd ]; then
            cp ~/.config/kanata/kanata.kbd ~/kanata-backup-$(date +%Y%m%d).kbd
            echo "Backed up config to ~/kanata-backup-$(date +%Y%m%d).kbd"
        fi
        rm -rf ~/.config/kanata
        echo "Removed config directory"
    fi
else
    echo " Kept config directory"
fi

# Remove logs
if [ -f /tmp/kanata.out.log ]; then
    rm /tmp/kanata.out.log
fi
if [ -f /tmp/kanata.err.log ]; then
    rm /tmp/kanata.err.log
fi
echo "Removed log files"

echo ""

# 3. Remove Karabiner Driver Services
echo -e "${YELLOW}🔧 Removing Karabiner driver services...${NC}"

driver_manager='org.pqrs.service.daemon.Karabiner-VirtualHIDDevice-Manager'
driver_daemon='org.pqrs.service.daemon.Karabiner-VirtualHIDDevice-Daemon'

for service in "$driver_manager" "$driver_daemon"; do
    if sudo launchctl list | grep -q "$service"; then
        sudo launchctl bootout system/"$service" 2>/dev/null || true
        echo "Stopped $service"
    fi
    
    if [ -f /Library/LaunchDaemons/${service}.plist ]; then
        sudo rm /Library/LaunchDaemons/${service}.plist
        echo "Removed ${service}.plist"
    fi
done

echo ""

# 4. Uninstall Karabiner DriverKit
echo -e "${YELLOW} Uninstalling Karabiner DriverKit...${NC}"

read -p "Uninstall Karabiner-DriverKit-VirtualHIDDevice? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    # Try Homebrew first
    if brew list --cask karabiner-driverkit-virtualHIDdevice &>/dev/null; then
        brew uninstall --cask karabiner-driverkit-virtualHIDdevice
        echo "Uninstalled via Homebrew"
    else
        # Manual removal
        if [ -d "/Applications/.Karabiner-VirtualHIDDevice-Manager.app" ]; then
            sudo rm -rf "/Applications/.Karabiner-VirtualHIDDevice-Manager.app"
            echo "Removed DriverKit Manager app"
        fi
        
        if [ -d "/Library/Application Support/org.pqrs/Karabiner-DriverKit-VirtualHIDDevice" ]; then
            sudo rm -rf "/Library/Application Support/org.pqrs/Karabiner-DriverKit-VirtualHIDDevice"
            echo "Removed DriverKit support files"
        fi
    fi
else
    echo "Kept Karabiner DriverKit"
fi

echo ""

# 5. Uninstall Karabiner-Elements (if installed)
echo -e "${YELLOW} Checking for Karabiner-Elements...${NC}"

if [ -d "/Applications/Karabiner-Elements.app" ]; then
    read -p "Found Karabiner-Elements. Uninstall it too? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        if brew list --cask karabiner-elements &>/dev/null; then
            brew uninstall --cask karabiner-elements
            echo "Uninstalled Karabiner-Elements via Homebrew"
        else
            sudo rm -rf "/Applications/Karabiner-Elements.app"
            rm -rf ~/.config/karabiner
            echo "Removed Karabiner-Elements manually"
        fi
    fi
fi

echo ""

# 6. Remove System Extension (Requires Restart)
echo -e "${YELLOW} System Extension Removal...${NC}"
echo ""
echo "To completely remove the Karabiner system extension:"
echo "  1. Go to: System Settings → Privacy & Security"
echo "  2. Scroll to 'Security' section"
echo "  3. Find 'org.pqrs.driverkit.Karabiner-DriverKit-VirtualHIDDevice'"
echo "  4. Click the (i) button and select 'Remove System Extension'"
echo "  5. Restart your Mac"
echo ""
read -p "Open System Settings now? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    open "x-apple.systempreferences:com.apple.preference.security?General"
fi

echo ""

# 7. Remove Accessibility Permissions
echo -e "${YELLOW} Removing Accessibility Permissions...${NC}"
echo ""
echo "To remove Kanata from Accessibility:"
echo "  1. Go to: System Settings → Privacy & Security → Accessibility"
echo "  2. Find '/Users/shrey99sh/.local/bin/kanata' in the list"
echo "  3. Select it and click the '-' button to remove"
echo ""
read -p "Open Accessibility settings now? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    open "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"
fi

echo ""

# 8. Restore macOS Settings (Optional)
echo -e "${YELLOW}  Restore macOS Settings...${NC}"
echo ""
read -p "Restore default macOS settings (Dock, keyboard, etc.)? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    # Restore Dock
    defaults write com.apple.dock autohide -bool false
    defaults delete com.apple.dock autohide-delay 2>/dev/null || true
    defaults delete com.apple.dock autohide-time-modifier 2>/dev/null || true
    defaults write com.apple.dock show-recents -bool true
    killall Dock
    echo "Restored Dock settings"
    
    # Restore animations
    defaults write com.apple.universalaccess reduceMotion -bool false
    defaults write com.apple.universalaccess reduceTransparency -bool false
    defaults delete NSGlobalDomain NSWindowResizeTime 2>/dev/null || true
    defaults delete NSGlobalDomain NSAutomaticWindowAnimationsEnabled 2>/dev/null || true
    killall SystemUIServer
    echo "Restored animation settings"
    
    # Restore keyboard settings
    defaults write NSGlobalDomain KeyRepeat -int 6
    defaults write NSGlobalDomain InitialKeyRepeat -int 25
    defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool true
    echo "Restored keyboard settings"
    
    # Restore focus ring
    defaults write com.apple.Accessibility KeyboardFocusIndicatorEnabled -bool true
    killall Dock
    echo "Restored focus ring"
fi

echo ""

# 9. Summary
echo -e "${GREEN} Uninstall Complete!${NC}"
echo ""
echo "What was removed:"
echo "  Kanata binary (~/.local/bin/kanata)"
echo "  Kanata service (LaunchAgent)"
echo "  Karabiner driver services (LaunchDaemons)"
echo "  Log files (/tmp/kanata.*)"
echo ""
echo "What you may need to do manually:"
echo "  ️  Remove system extension (System Settings → Security)"
echo "  ️  Remove Accessibility permissions (System Settings → Accessibility)"
echo "  ️  Restart your Mac (to fully remove system extension)"
echo ""
echo "Config backup saved to: ~/kanata-backup-$(date +%Y%m%d).kbd"
echo ""

read -p "Restart Mac now to complete uninstall? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo " Restarting in 5 seconds... (Ctrl+C to cancel)"
    sleep 5
    sudo shutdown -r now
else
    echo ""
    echo "️  Remember to restart later to complete the uninstall!"
fi
