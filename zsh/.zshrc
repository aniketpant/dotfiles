# start profiler (disabled for production use - uncomment to profile)
# zmodload zsh/zprof  

# shortcut to this dotfiles path is $ZSH
export DOTFILES=$HOME/.dotfiles

# history
setopt hist_ignore_all_dups hist_save_nodups

# ============================================================================
# ZINIT PLUGIN MANAGER SETUP
# ============================================================================
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
[ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "${ZINIT_HOME}/zinit.zsh"

# Load fzf-bin with turbo mode for faster startup
zinit ice wait'0' lucid from"gh-r" as"program"
zinit light junegunn/fzf-bin

zinit wait lucid for \
    zdharma/history-search-multi-word \
    OMZ::plugins/git \
    lukechilds/zsh-nvm

# Load fzf-tab with turbo mode (depends on fzf-bin)
zinit ice wait'0a' lucid light-mode
zinit light Aloxaf/fzf-tab

zinit wait lucid light-mode for \
  atinit"ZINIT[COMPINIT_OPTS]=-C; zpcompinit; zpcdreplay" \
    zdharma/fast-syntax-highlighting \
  atload"!_zsh_autosuggest_start" \
    zsh-users/zsh-autosuggestions \
  blockf \
    zsh-users/zsh-completions

# Defer tool initialization to speed up shell startup
zinit wait'0a' lucid atload'eval "$(zoxide init zsh)"; eval "$(direnv hook zsh)"' for \
    zdharma-continuum/null

# JAVA_HOME - defer to avoid subprocess call during startup
zinit wait'0c' lucid atload'export JAVA_HOME="$(/usr/libexec/java_home -v11 -aarm64)"; export PATH=$JAVA_HOME/bin:$PATH' for \
    zdharma-continuum/null

# ============================================================================
# LOAD LOCAL CONFIG FILES
# ============================================================================
# source every .zsh file in this repo (config, aliases, etc)
for config_file ($DOTFILES/**/*.zsh) source $config_file

# Load profile (contains consolidated PATH and environment variables)
source $HOME/.profile

# ============================================================================
# SHELL OPTIONS
# ============================================================================
unsetopt ignoreeof nomatch

# use .localrc for SUPER SECRET CRAP that you don't
# want in your public, versioned repo
if [[ -a $HOME/.localrc ]]
then
  source $HOME/.localrc
fi

# ============================================================================
# HOMEBREW & PROMPT INITIALIZATION
# ============================================================================
if type brew &>/dev/null; then
  # Cache brew prefix - hardcoded for performance (update if Homebrew location changes)
  FPATH=/opt/homebrew/share/zsh/site-functions:$FPATH
  brew analytics off 2>&1 >/dev/null
fi

zstyle ':vcs_info:*' disable-patterns "$HOME/Uber/(go-code|fievel)(|/*)"
# Initialize Starship prompt
eval "$(starship init zsh)"

# ============================================================================
# LAZY-LOADED TOOLS
# ============================================================================

# Lazy load SDKMAN - only initialize on first use
export SDKMAN_DIR="$HOME/.sdkman"
sdk() {
    unfunction sdk
    [[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"
    sdk "$@"
}

# Use zinit lazy-loading for NVM (already configured above via zsh-nvm plugin)
export NVM_LAZY_LOAD=true

# ============================================================================
# FZF KEYBINDINGS (loaded after fzf-bin turbo load)
# ============================================================================
# Source fzf keybindings and completions if available
zinit wait'0b' lucid has'fzf' for \
    atload'source "$HOME/.local/share/zinit/plugins/junegunn---fzf-bin/shell/key-bindings.zsh 2>/dev/null; source "$HOME/.local/share/zinit/plugins/junegunn---fzf-bin/shell/completion.zsh 2>/dev/null"' \
    zdharma-continuum/null

# ============================================================================
# OPTIONAL INTEGRATIONS
# ============================================================================

# iTerm2 shell integration (if available)
test -e /Users/aniketp/.iterm2_shell_integration.zsh && source /Users/aniketp/.iterm2_shell_integration.zsh || true

# Bun JavaScript runtime
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
# Bun completions (if available)
[ -s "/Users/aniketp/.bun/_bun" ] && source "/Users/aniketp/.bun/_bun"

# pi agent bin — must be AFTER bun so the real pi binary wins over the
# bun-installed npm wrapper (@earendil-works/pi-coding-agent).
export PATH="$HOME/.pi/agent/bin:$PATH"

# ============================================================================
# PROFILING (Disabled by default - uncomment to profile startup time)
# ============================================================================
# zprof
