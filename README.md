# dotfiles

Personal Zsh dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Structure

```
.dotfiles/
├── bin/              # git helper scripts (stowed to ~/bin)
├── git/
│   ├── .gitconfig    # global git config (personal email)
│   ├── .gitignore    # global gitignore
│   └── .gitmessage   # commit message template
├── scripts/
│   └── setup-ubuntu.sh # Ubuntu package & repository installer
├── starship/
│   └── .config/
│       └── starship.toml  # prompt config
├── zsh/
│   ├── .zshrc        # main entry point (zinit + turbo mode)
│   ├── aliases.zsh   # shell aliases (auto-sourced)
│   ├── config.zsh    # zsh options, history, key bindings
│   ├── prompt.zsh    # prompt config (Starship handles this)
│   ├── window.zsh    # terminal window title helper
│   └── functions/    # autoloaded zsh functions
└── Makefile          # install / clean / update / setup targets
```

## Install

### 1. Ubuntu Package Setup

On Ubuntu, install system packages, repositories, and modern CLI tools:

```sh
git clone https://github.com/aniketp/dotfiles ~/.dotfiles
cd ~/.dotfiles
make setup-ubuntu
```

This installs:
- **Terminal & Editors:** [Ghostty](https://ghostty.org), Neovim, Vim
- **Git & Pagers:** `git-delta` (syntax-highlighted pager), `bat` (modern `cat`)
- **Shell & Utilities:** `zsh`, GNU Stow, `eza` (via official Gierens APT repo), `fzf`, `direnv`, `starship`, `zoxide`, `ripgrep`

### 2. Stow Configurations

```sh
make install
```

`make install` stows `git`, `zsh`, `bin`, and `starship` into `$HOME`.


## Plugin Manager

[Zinit](https://github.com/zdharma-continuum/zinit) with turbo mode for
deferred plugin loading. Shell startup is ~0.6s.

| Plugin | Purpose |
|--------|---------|
| `zdharma/fast-syntax-highlighting` | Syntax highlighting |
| `zsh-users/zsh-autosuggestions` | Fish-like suggestions |
| `zsh-users/zsh-completions` | Extended completions |
| `Aloxaf/fzf-tab` | fzf-powered completions |
| `junegunn/fzf-bin` | Fuzzy finder binary |
| `zdharma/history-search-multi-word` | Better Ctrl-R |
| `lukechilds/zsh-nvm` | Lazy-loaded NVM |

## Tools

| Tool | Purpose |
|------|---------|
| [starship](https://starship.rs) | Cross-shell prompt |
| [zoxide](https://github.com/ajeetdsouza/zoxide) | Smart `z` directory jump |
| [direnv](https://direnv.net) | Directory-specific env vars |
| [fzf](https://github.com/junegunn/fzf) | Fuzzy finder (Ctrl-T, Ctrl-R, Alt-C) |
| [eza](https://github.com/eza-community/eza) | Modern `ls` replacement |
| [bat](https://github.com/sharkdp/bat) | Modern `cat` replacement |
| [delta](https://github.com/dandavison/delta) | Syntax-highlighted git diff |

## Work Machine Setup

The `.gitconfig` uses `includeIf` to conditionally include
`~/.gitconfig-work` when working inside `~/work/`. Create that file on
work machines with work-specific user, credentials, and URL rewrites.

## Local Overrides

Add machine-specific config to `~/.localrc` (not version-controlled):

```zsh
export WORK_TOKEN=...
```

## Profiling Startup Time

Uncomment the two `zprof` lines in `.zshrc`:

```zsh
zmodload zsh/zprof  # top of .zshrc
zprof               # bottom of .zshrc
```

Then run `zsh -i -c exit` and read the report.
