#!/usr/bin/env bash
# ==============================================================================
# macOS-style Keybindings for GNOME / Ubuntu
# ==============================================================================
# Applies the parts of the macOS "Cmd" workflow that live in GNOME settings
# (they aren't plain files, so GNU Stow can't manage them):
#
#   1. GTK "Emacs" key theme
#        Ctrl+A/E/K/F/B/N/P text editing in every GTK text field, matching
#        macOS text fields.
#
#   2. Frees <Super>v (Cmd+V)
#        GNOME binds <Super>v to the message tray, which would swallow the
#        Cmd+V paste binding defined in ghostty/config.
#
# Terminal-level bindings live in ghostty/.config/ghostty/config.
# Shell-level fallbacks live in zsh/config.zsh.
#
# Usage:
#   ./scripts/setup-macos-keys.sh          # apply
#   ./scripts/setup-macos-keys.sh --revert # restore GNOME defaults
# ==============================================================================

set -euo pipefail

BOLD="\033[1m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
RED="\033[0;31m"
RESET="\033[0m"

log_info()    { printf "${BLUE}==>${RESET} ${BOLD}%s${RESET}\n" "$1"; }
log_success() { printf "${GREEN}==>${RESET} ${BOLD}%s${RESET}\n" "$1"; }
log_warn()    { printf "${YELLOW}WARNING:${RESET} %s\n" "$1"; }
log_error()   { printf "${RED}ERROR:${RESET} %s\n" "$1" >&2; }

# --- Preconditions -----------------------------------------------------------
if ! command -v gsettings >/dev/null 2>&1; then
    log_error "gsettings not found. This script requires GNOME."
    exit 1
fi

if [[ "${XDG_CURRENT_DESKTOP:-}" != *GNOME* && "${XDG_CURRENT_DESKTOP:-}" != *gnome* ]]; then
    log_warn "XDG_CURRENT_DESKTOP is '${XDG_CURRENT_DESKTOP:-unset}', not GNOME."
    log_warn "Applying anyway; settings will take effect if/when you log into GNOME."
fi

# --- Revert mode -------------------------------------------------------------
if [[ "${1:-}" == "--revert" ]]; then
    log_info "Reverting macOS-style GNOME settings..."

    gsettings reset org.gnome.desktop.interface gtk-key-theme
    gsettings set org.gnome.shell.keybindings toggle-message-tray "['<Super>v', '<Super>m']"

    log_success "Reverted. Restart GTK apps (and log out/in) for the key theme to reset."
    exit 0
fi

if [[ -n "${1:-}" ]]; then
    log_error "Unknown argument: $1"
    echo "Usage: $0 [--revert]"
    exit 1
fi

# --- Apply -------------------------------------------------------------------
log_info "Enabling the GTK 'Emacs' key theme (macOS-style text editing)..."
gsettings set org.gnome.desktop.interface gtk-key-theme 'Emacs'

log_info "Freeing <Super>v so Cmd+V reaches the terminal..."
gsettings set org.gnome.shell.keybindings toggle-message-tray "['<Super>m']"

log_success "macOS-style GNOME settings applied."
echo
echo "  gtk-key-theme          : $(gsettings get org.gnome.desktop.interface gtk-key-theme)"
echo "  toggle-message-tray    : $(gsettings get org.gnome.shell.keybindings toggle-message-tray)"
echo
log_info "Restart open GTK apps so they pick up the new key theme."
log_info "Revert with: $0 --revert"
