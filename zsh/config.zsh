# ============================================================================
# ZSH CONFIGURATION
# ============================================================================

# ----------------------------------------------------------------------------
# Colors
# ----------------------------------------------------------------------------
# LSCOLORS is the BSD/macOS form (colon-separated descriptors, no `=`).
export LSCOLORS="exfxcxdxbxegedabagacad"
export CLICOLOR=true
# LS_COLORS is the GNU form and is what the zsh completion `list-colors` zstyle
# below, eza, and coreutils `ls` read. It is not exported by anything on Ubuntu
# outside bash, so without this the zstyle expands to an empty value and file
# completions lose their colors. This is `dircolors -b`'s default; override it
# in ~/.localrc, which .zshrc sources after this file.
export LS_COLORS="${LS_COLORS:-di=34:ln=35:so=32:pi=33:ex=31:bd=34:cd=34:su=37:sg=37:tw=32:ow=32}"

# ----------------------------------------------------------------------------
# Functions path
# ----------------------------------------------------------------------------
fpath=($DOTFILES/zsh/functions $fpath)

# Eager-load utility functions (non-completion) so they're available immediately
autoload -U c h gf last_modified newtab savepath smartextract verbose_completion

# ----------------------------------------------------------------------------
# Project root
# ----------------------------------------------------------------------------
# `c` (zsh/functions/c) and its completion (_c) both resolve against $PROJECTS,
# and nothing defined it, so `c foo` ran `cd /foo` and completion listed `/`.
# Override in ~/.localrc, which .zshrc sources after this file.
export PROJECTS="${PROJECTS:-$HOME/Playground}"

# ----------------------------------------------------------------------------
# History configuration
# ----------------------------------------------------------------------------
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000

setopt EXTENDED_HISTORY          # save timestamp and duration in history
setopt INC_APPEND_HISTORY        # append to history file incrementally, not on exit
setopt SHARE_HISTORY             # share history across all open shells
setopt HIST_IGNORE_DUPS          # ignore consecutive duplicate commands
setopt HIST_IGNORE_ALL_DUPS      # remove older duplicates from history
setopt HIST_FIND_NO_DUPS         # don't show duplicates in history search
setopt HIST_SAVE_NO_DUPS         # don't write duplicates when saving
setopt HIST_REDUCE_BLANKS        # strip extra blanks from history entries
setopt HIST_VERIFY               # confirm history expansion before executing

# ----------------------------------------------------------------------------
# Shell behavior
# ----------------------------------------------------------------------------
setopt NO_BG_NICE           # don't nice background tasks
setopt NO_HUP               # don't kill background jobs when shell exits
setopt NO_LIST_BEEP         # don't beep on ambiguous completion
setopt LOCAL_OPTIONS        # allow functions to have local options
setopt LOCAL_TRAPS          # allow functions to have local traps
setopt PROMPT_SUBST         # allow variable substitution in prompts
setopt CORRECT              # suggest corrections for mistyped commands
setopt COMPLETE_IN_WORD     # complete from cursor position, not end of word
# IGNORE_EOF is deliberately not set: .zshrc unsets it after sourcing this
# file, so Ctrl-D on an empty line exits. Setting it here only described
# behavior that never took effect.
setopt AUTO_CD              # type a directory name to cd into it
setopt AUTO_PUSHD           # cd pushes old dir onto stack (use `dirs -v` to see)
setopt PUSHD_IGNORE_DUPS    # don't push duplicate directories on the stack
setopt PUSHD_SILENT         # don't print stack after pushd/popd
setopt GLOB_DOTS            # * matches dotfiles too
setopt INTERACTIVE_COMMENTS # allow # comments in interactive shell

# ----------------------------------------------------------------------------
# Completion
# ----------------------------------------------------------------------------
# Case-insensitive and partial-word completion
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
# Group completions by type with headers
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'
# Show menu when there are multiple completions
zstyle ':completion:*' menu select
# Colorize file completions like ls
zstyle ':completion:*:default' list-colors "${(s.:.)LS_COLORS}"

# ----------------------------------------------------------------------------
# Key bindings
# ----------------------------------------------------------------------------
zle -N newtab

bindkey -e                          # use emacs key bindings (default for zsh)
bindkey '^[^[[D' backward-word      # alt+left: move back one word
bindkey '^[^[[C' forward-word       # alt+right: move forward one word
bindkey '^[[5D' beginning-of-line   # ctrl+left: beginning of line
bindkey '^[[5C' end-of-line         # ctrl+right: end of line
bindkey '^[[3~' delete-char         # delete: delete character under cursor
bindkey '^[^N' newtab              # alt+N: open new tab
bindkey '^?' backward-delete-char  # backspace: delete char before cursor
# Ctrl-R: search history (enhanced by history-search-multi-word plugin)
bindkey '^R' history-incremental-search-backward

# macOS-style (Cmd/Super) fallbacks. Ghostty translates Cmd+Left/Right/Backspace
# into readline control chars (see ghostty/config), so these only matter for
# terminals that forward raw Super-modified escape sequences (xterm modifier 9).
bindkey '^[[1;9D' beginning-of-line      # cmd+left
bindkey '^[[1;9C' end-of-line            # cmd+right
bindkey '^[[1;9A' beginning-of-buffer-or-history  # cmd+up
bindkey '^[[1;9B' end-of-buffer-or-history        # cmd+down
bindkey '^[[3;9~' delete-char            # cmd+delete
