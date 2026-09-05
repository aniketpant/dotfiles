# ============================================================================
# ALIASES
# ============================================================================

# ----------------------------------------------------------------------------
# Shell
# ----------------------------------------------------------------------------
alias reload!='exec zsh'           # full shell reload (exec, not source)
alias src='. ~/.zshrc'             # source without reloading
alias zshrc='${EDITOR:-vi} $DOTFILES/zsh/.zshrc'
alias dotfiles='cd $DOTFILES'

# ----------------------------------------------------------------------------
# Navigation
# ----------------------------------------------------------------------------
alias h='cd ~/'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias -- -='cd -'                  # go back to previous directory

# ----------------------------------------------------------------------------
# Listing (eza: modern ls replacement)
# ----------------------------------------------------------------------------
if command -v eza &>/dev/null; then
  alias ls='eza --group-directories-first'
  alias ll='eza -lh --group-directories-first'         # long list
  alias la='eza -lah --group-directories-first'        # long list, show hidden
  alias lt='eza --tree --level=2'                      # tree (2 levels)
  alias llt='eza -lh --tree --level=2'                 # long list + tree
else
  alias ll='ls -lh'
  alias la='ls -lah'
fi

# ----------------------------------------------------------------------------
# File operations
# ----------------------------------------------------------------------------
alias cp='cp -iv'                  # interactive + verbose
alias mv='mv -iv'                  # interactive + verbose
alias mkdir='mkdir -pv'            # create parent dirs, verbose
alias rmdir='rmdir -v'
alias df='df -h'                   # human-readable disk usage
alias du='du -sh'                  # disk usage, summary + human-readable

# ----------------------------------------------------------------------------
# Searching
# ----------------------------------------------------------------------------
# Keep grep as grep — aliased grep=rg breaks scripts and pipes.
# Use rg directly for ripgrep.
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias rgi='rg -i'

# ----------------------------------------------------------------------------
# Editors
# ----------------------------------------------------------------------------
alias vi='vim'
alias e='${EDITOR:-vi}'

# ----------------------------------------------------------------------------
# Git (common shortcuts on top of OMZ git plugin)
# ----------------------------------------------------------------------------
alias g='git'
alias gs='git status -sb'          # short status
alias ga='git add'
alias gaa='git add --all'
alias gc='git commit -v'
alias gcm='git commit -m'
alias gca='git commit --amend --no-edit'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gd='git diff'
alias gds='git diff --staged'
alias gl='git log --oneline --graph --decorate -20'
alias gll='git log --oneline --graph --decorate'
alias gp='git push'
alias gpl='git pull --rebase'
alias gb='git branch'
alias gbD='git branch -D'
alias gst='git stash'
alias gsp='git stash pop'
alias grb='git rebase'
alias grbi='git rebase -i'
alias grhh='git reset --hard HEAD'  # discard all local changes
alias gwip='git add -A && git commit -m "WIP: checkpoint [skip ci]"'  # quick checkpoint commit

# ----------------------------------------------------------------------------
# Process management
# ----------------------------------------------------------------------------
alias psg='ps aux | grep'          # search processes
alias k9='kill -9'
alias ports='lsof -i -P -n | grep LISTEN'  # show listening ports

# ----------------------------------------------------------------------------
# Networking
# ----------------------------------------------------------------------------
alias myip='curl -s https://api.ipify.org && echo'  # public IP
alias localip="ipconfig getifaddr en0"              # local IP

# ----------------------------------------------------------------------------
# macOS utilities
# ----------------------------------------------------------------------------
alias o='open .'                           # open in Finder
alias ql='qlmanage -p'                     # Quick Look preview
alias flushdns='sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder'
alias showfiles='defaults write com.apple.finder AppleShowAllFiles TRUE; killall Finder'
alias hidefiles='defaults write com.apple.finder AppleShowAllFiles FALSE; killall Finder'
alias cleanup='find . -name "*.DS_Store" -type f -delete'  # remove .DS_Store files

# ----------------------------------------------------------------------------
# Development utilities
# ----------------------------------------------------------------------------
alias py='python3'
alias pip='pip3'
alias serve='python3 -m http.server'       # quick local web server
alias json='python3 -m json.tool'          # pretty-print JSON from stdin
alias urldecode='python3 -c "import sys, urllib.parse; print(urllib.parse.unquote(sys.stdin.read().strip()))"'

# ----------------------------------------------------------------------------
# Zoxide (smart cd replacement — use z/zi instead of cd)
# ----------------------------------------------------------------------------
alias z='z'
alias zi='zi'

# ----------------------------------------------------------------------------
# Clipboard
# ----------------------------------------------------------------------------
alias pbp='pbpaste'
alias pbc='pbcopy'
alias pwdc='pwd | tr -d "\n" | pbcopy'     # copy current path to clipboard

# ----------------------------------------------------------------------------
# Homebrew
# ----------------------------------------------------------------------------
alias brewup='brew update && brew upgrade && brew cleanup'
