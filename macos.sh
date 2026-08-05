#!/usr/bin/env bash
#
# Opt-in macOS system defaults, applied by: ./install.sh <mode> --with-macos-defaults
# Deliberately conservative; review before running.
#
set -euo pipefail

# Keyboard: fast repeat, no press-and-hold accent picker
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

# Finder: show extensions, path bar, status bar, default to list view
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

# Dock: no recent apps section (size and position untouched)
defaults write com.apple.dock show-recents -bool false

# Screenshots into their own folder instead of the Desktop
mkdir -p "$HOME/Screenshots"
defaults write com.apple.screencapture location -string "$HOME/Screenshots"

# Trackpad: tap to click
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true

killall Finder Dock SystemUIServer 2>/dev/null || true
echo "macOS defaults applied; keyboard settings take effect after logout/login"
