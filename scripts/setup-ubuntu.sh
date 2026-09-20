#!/usr/bin/env bash
# ==============================================================================
# Ubuntu Setup Script for Personal Dotfiles
# ==============================================================================
# Installs core utilities, modern CLI tools, terminal emulator, and editors:
# - ghostty
# - git-delta (delta)
# - bat (symlinked to ~/.local/bin/bat if installed as batcat)
# - eza (via official gierens.de APT repository)
# - fzf
# - neovim & vim
# - direnv
# - starship
# - zoxide
# - stow, zsh, git, ripgrep
# ==============================================================================

set -euo pipefail

# Text styling
BOLD="\033[1m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
RED="\033[0;31m"
RESET="\033[0m"

log_info() {
    printf "${BLUE}==>${RESET} ${BOLD}%s${RESET}\n" "$1"
}

log_success() {
    printf "${GREEN}==>${RESET} ${BOLD}%s${RESET}\n" "$1"
}

log_warn() {
    printf "${YELLOW}WARNING:${RESET} %s\n" "$1"
}

log_error() {
    printf "${RED}ERROR:${RESET} %s\n" "$1" >&2
}

# 1. Verify OS is Debian/Ubuntu
if [ ! -f /etc/os-release ]; then
    log_error "This script requires an Ubuntu/Debian system."
    exit 1
fi

. /etc/os-release
if [[ "${ID:-}" != "ubuntu" && "${ID_LIKE:-}" != *"debian"* && "${ID_LIKE:-}" != *"ubuntu"* ]]; then
    log_warn "Detected OS is '${ID:-unknown}'. This script is tailored for Ubuntu/Debian."
fi

# 2. Acquire sudo credentials upfront
if [ "$(id -u)" -ne 0 ]; then
    log_info "Requesting sudo privileges..."
    sudo -v
    # Keep sudo alive in background
    while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
    SUDO_PID=$!
    trap 'kill "$SUDO_PID" 2>/dev/null || true' EXIT
fi

# 3. Update base packages and install essential pre-requisites
log_info "Installing prerequisite utilities..."
sudo apt-get update -qq
sudo apt-get install -y -qq \
    ca-certificates \
    curl \
    wget \
    gpg \
    gpg-agent \
    software-properties-common \
    build-essential

# 4. Configure third-party repositories
# ------------------------------------------------------------------------------
# eza repository (official community deb repo)
# ------------------------------------------------------------------------------
log_info "Configuring eza APT repository..."
sudo mkdir -p -m 0755 /etc/apt/keyrings
wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | \
    sudo gpg --dearmor --yes -o /etc/apt/keyrings/gierens.gpg
sudo chmod 644 /etc/apt/keyrings/gierens.gpg

echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | \
    sudo tee /etc/apt/sources.list.d/gierens.list > /dev/null
sudo chmod 644 /etc/apt/sources.list.d/gierens.list

# ------------------------------------------------------------------------------
# Ghostty PPA (for Ubuntu versions where ghostty is not in the base archive)
# ------------------------------------------------------------------------------
if ! apt-cache show ghostty >/dev/null 2>&1; then
    log_info "Ghostty not found in current repositories. Adding PPA: ppa:mkasberg/ghostty-ubuntu..."
    sudo add-apt-repository -y ppa:mkasberg/ghostty-ubuntu
fi

# 5. Update package lists with newly configured repositories
log_info "Updating package lists..."
sudo apt-get update -qq

# 6. Install target packages
PACKAGES=(
    git
    stow
    zsh
    direnv
    fzf
    bat
    git-delta
    eza
    neovim
    vim
    ripgrep
)

# Optional / version-dependent packages in apt
if apt-cache show ghostty >/dev/null 2>&1; then
    PACKAGES+=(ghostty)
else
    log_warn "Package 'ghostty' could not be found via APT for this distribution release."
fi

if apt-cache show starship >/dev/null 2>&1; then
    PACKAGES+=(starship)
fi

if apt-cache show zoxide >/dev/null 2>&1; then
    PACKAGES+=(zoxide)
fi

log_info "Installing APT packages: ${PACKAGES[*]}..."
sudo apt-get install -y "${PACKAGES[@]}"

# 7. Post-installation setup
# ------------------------------------------------------------------------------
# Ensure ~/.local/bin exists and is in PATH
# ------------------------------------------------------------------------------
LOCAL_BIN="$HOME/.local/bin"
mkdir -p "$LOCAL_BIN"

# Debian/Ubuntu installs bat as 'batcat'. Provide 'bat' symlink if missing.
if command -v batcat >/dev/null 2>&1; then
    if ! command -v bat >/dev/null 2>&1 || [ "$(command -v bat)" = "$LOCAL_BIN/bat" ]; then
        log_info "Creating symlink for bat (${LOCAL_BIN}/bat -> $(command -v batcat))..."
        ln -sf "$(command -v batcat)" "$LOCAL_BIN/bat"
    fi
fi

# Install Starship via official installer if not available via APT
if ! command -v starship >/dev/null 2>&1; then
    log_info "Installing starship prompt via official script..."
    curl -sS https://starship.rs/install.sh | sh -s -- -y
fi

# Install Zoxide via official installer if not available via APT
if ! command -v zoxide >/dev/null 2>&1; then
    log_info "Installing zoxide via official script..."
    curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
fi

# 8. Summary of installed tools
log_success "Ubuntu setup complete! Installed tool status:"
printf "\n"
for cmd in ghostty delta bat eza fzf nvim vim direnv starship zoxide stow zsh rg; do
    if command -v "$cmd" >/dev/null 2>&1; then
        printf "  %-10s : %s (%s)\n" "$cmd" "${GREEN}installed${RESET}" "$(command -v "$cmd")"
    else
        printf "  %-10s : %s\n" "$cmd" "${RED}not found${RESET}"
    fi
done
printf "\n"

log_info "Next steps:"
echo "  1. Link your dotfiles:  make install"
if [ "${SHELL##*/}" != "zsh" ]; then
    echo "  2. Set zsh as default:  chsh -s \$(which zsh)"
fi
echo "  3. Open a new terminal or restart your session."
