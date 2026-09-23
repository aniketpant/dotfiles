#!/usr/bin/env bash
# ==============================================================================
# keyd Setup — macOS-style "Cmd" layer + per-app profiles (Wayland-friendly)
# ==============================================================================
# Installs and wires up:
#   - keyd                    (global Cmd layer, from keyd/default.conf)
#   - keyd-application-mapper (per-app masks, from keyd/app.conf)
#   - the keyd GNOME extension (lets the mapper see the focused window)
#
# keyd remaps at the evdev layer, so it works on Wayland (unlike xkeysnail /
# Kinto), X11, and the TTY alike.
#
# Usage:
#   ./scripts/setup-keyd.sh          # install + enable
#   ./scripts/setup-keyd.sh --revert # disable + restore previous config
#
# NOTE: a re-login is required afterwards — the keyd group membership and the
# GNOME extension only take effect in a fresh session.
# ==============================================================================

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_SRC="$REPO_DIR/keyd/default.conf"
APP_CONFIG_SRC="$REPO_DIR/keyd/app.conf"
CONFIG_DST="/etc/keyd/default.conf"
APP_CONFIG_DST="$HOME/.config/keyd/app.conf"
SERVICE="keyd"
EXT_SRC="/usr/share/keyd/gnome-extension-45"
EXT_DST="$HOME/.local/share/gnome-shell/extensions/keyd"
TARGET_USER="${SUDO_USER:-$USER}"

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
if [ ! -f /etc/os-release ]; then
    log_error "This script requires an Ubuntu/Debian system."
    exit 1
fi

if [ ! -f "$CONFIG_SRC" ] || [ ! -f "$APP_CONFIG_SRC" ]; then
    log_error "Missing keyd config in $REPO_DIR/keyd/"
    exit 1
fi

# --- Revert mode -------------------------------------------------------------
if [[ "${1:-}" == "--revert" ]]; then
    log_info "Disabling keyd, the mapper, and the GNOME extension..."

    gnome-extensions disable keyd 2>/dev/null || true
    pkill -f keyd-application-mapper 2>/dev/null || true
    rm -rf "$EXT_DST"
    rm -f "$APP_CONFIG_DST"

    sudo systemctl disable --now "$SERVICE" 2>/dev/null || true

    if [ -L "$CONFIG_DST" ]; then
        sudo rm -f "$CONFIG_DST"
    fi
    if [ -f "$CONFIG_DST.bak" ]; then
        sudo mv "$CONFIG_DST.bak" "$CONFIG_DST"
        log_info "Restored previous /etc/keyd/default.conf"
    fi

    sudo gpasswd -d "$TARGET_USER" keyd 2>/dev/null || true

    log_success "Reverted."
    log_info "Remove packages with: sudo apt remove keyd keyd-application-mapper"
    exit 0
fi

if [[ -n "${1:-}" ]]; then
    log_error "Unknown argument: $1"
    echo "Usage: $0 [--revert]"
    exit 1
fi

# --- Acquire sudo ------------------------------------------------------------
if [ "$(id -u)" -ne 0 ]; then
    log_info "Requesting sudo privileges..."
    sudo -v
fi

# --- Install packages --------------------------------------------------------
log_info "Installing keyd and keyd-application-mapper..."
sudo apt-get update -qq
sudo apt-get install -y keyd keyd-application-mapper

# --- keyd group (for /var/run/keyd.socket access by the mapper) --------------
log_info "Ensuring 'keyd' group and membership..."
sudo groupadd -f keyd
RELOGIN=0
if ! id -nG "$TARGET_USER" | tr ' ' '\n' | grep -qx keyd; then
    sudo usermod -aG keyd "$TARGET_USER"
    RELOGIN=1
fi

# --- Global config -----------------------------------------------------------
sudo mkdir -p /etc/keyd
if [ -f "$CONFIG_DST" ] && [ ! -L "$CONFIG_DST" ]; then
    sudo cp "$CONFIG_DST" "$CONFIG_DST.bak"
    log_warn "Existing config backed up to $CONFIG_DST.bak"
fi
log_info "Linking $CONFIG_DST -> $CONFIG_SRC"
sudo ln -sfn "$CONFIG_SRC" "$CONFIG_DST"

# --- Per-app config ----------------------------------------------------------
mkdir -p "$HOME/.config/keyd"
log_info "Linking $APP_CONFIG_DST -> $APP_CONFIG_SRC"
ln -sfn "$APP_CONFIG_SRC" "$APP_CONFIG_DST"

# --- GNOME extension (lets the mapper see the focused window) ----------------
if [ -d "$EXT_SRC" ]; then
    log_info "Installing the keyd GNOME extension..."
    mkdir -p "$(dirname "$EXT_DST")"
    rm -rf "$EXT_DST"
    cp -r "$EXT_SRC" "$EXT_DST"

    # The bundled metadata only lists GNOME 42-46; extend it to the running shell.
    shell_major="$(gnome-shell --version 2>/dev/null | grep -oE '[0-9]+' | head -1 || true)"
    if [ -n "$shell_major" ] && command -v python3 >/dev/null 2>&1; then
        python3 - "$EXT_DST/metadata.json" "$shell_major" <<'PY'
import json, sys
path, major = sys.argv[1], sys.argv[2]
with open(path) as fh:
    meta = json.load(fh)
versions = meta.get("shell-version", [])
if major not in versions:
    versions.append(major)
meta["shell-version"] = versions
with open(path, "w") as fh:
    json.dump(meta, fh, indent=2)
    fh.write("\n")
PY
        log_info "Patched extension metadata for GNOME $shell_major."
    else
        log_warn "Could not detect GNOME version; extension may not load."
    fi
else
    log_warn "GNOME extension not found at $EXT_SRC; per-app profiles will not work."
fi

# --- Start keyd --------------------------------------------------------------
log_info "Enabling and restarting keyd..."
sudo systemctl enable "$SERVICE" >/dev/null 2>&1 || true
sudo systemctl restart "$SERVICE"

sleep 0.5
if systemctl is-active --quiet "$SERVICE"; then
    log_success "keyd is running."
else
    log_error "keyd failed to start. Recent logs:"
    sudo journalctl -u "$SERVICE" -n 20 --no-pager || true
    exit 1
fi

# --- Enable the extension ----------------------------------------------------
if command -v gnome-extensions >/dev/null 2>&1; then
    if ! gnome-extensions enable keyd 2>/dev/null; then
        # Shell hasn't scanned the new extension yet — persist it in dconf so it
        # loads on next login.
        current="$(gsettings get org.gnome.shell enabled-extensions 2>/dev/null || echo "@as []")"
        if [[ "$current" != *"'keyd'"* ]]; then
            if [[ "$current" == "@as []" || "$current" == "[]" ]]; then
                gsettings set org.gnome.shell enabled-extensions "['keyd']"
            else
                gsettings set org.gnome.shell enabled-extensions "${current%]}, 'keyd']"
            fi
        fi
    fi
fi

# --- Summary -----------------------------------------------------------------
echo
echo "  Global config : $CONFIG_DST"
echo "  Per-app config: $APP_CONFIG_DST"
echo "  Extension     : $EXT_DST"
echo "  Debug classes : tail -f ~/.config/keyd/app.log"
echo

if [ "$RELOGIN" -eq 1 ]; then
    log_warn "Added $TARGET_USER to the 'keyd' group."
fi
log_warn "Log out and back in — the keyd group and the GNOME extension only take effect on the next login."
log_warn "If the mapper still logs a socket permission error afterwards, REBOOT: with KillUserProcesses=no the systemd user manager can keep the old group list across a logout."
log_info "Revert with: $0 --revert"
