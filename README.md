# dotfiles

Personal Zsh dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Structure

```
.dotfiles/
├── bin/              # git helper scripts (stowed to ~/bin)
├── ghostty/
│   └── .config/
│       └── ghostty/
│           ├── config     # terminal config (font, theme, keybindings)
│           └── themes/    # pi-matched light/dark palettes
├── opencode/
│   └── .config/
│       └── opencode/
│           └── cli.json   # TUI settings (theme, session, animations)
├── pi/
│   └── .pi/
│       └── agent/
│           └── settings.json  # pi TUI settings (theme, model, behaviour)
├── git/
│   ├── .gitconfig    # global git config (personal email)
│   ├── .gitignore    # global gitignore
│   └── .gitmessage   # commit message template
├── keyd/
│   ├── default.conf  # global macOS-style Cmd layer (installed to /etc/keyd)
│   └── app.conf      # per-app masks (installed to ~/.config/keyd)
├── scripts/
│   ├── setup-ubuntu.sh      # Ubuntu package & repository installer
│   ├── setup-macos-keys.sh  # GNOME macOS-style keybinding setup
│   └── setup-keyd.sh        # keyd Cmd-layer installer
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
└── Makefile          # install / clean / update / setup / macos-keys / keyd targets
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

`make install` stows `git`, `zsh`, `bin`, `starship`, `ghostty`, `opencode`, and
`pi` into `$HOME`.

## Theme Sync

Ghostty, pi, and opencode share one palette so moving between the shell and a
TUI is not jarring.

| App | Setting | Follows |
|-----|---------|---------|
| Ghostty | `theme = dark:pi-dark,light:pi-light` + `window-theme = auto` | GNOME light/dark |
| pi | `"theme": "light/dark"` | terminal appearance |
| opencode | `"name": "system"`, `"mode": "system"` | terminal appearance |

`ghostty/.config/ghostty/themes/pi-dark` and `pi-light` are generated from pi's
own bundled `dark.json` / `light.json` colors, so the shell prompt and pi's TUI
render from identical hex values. Switching GNOME light/dark moves all three.

To change the palette, edit the two theme files and reload Ghostty with
`Ctrl+Shift+Comma`.

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

## macOS-style Keybindings

The dotfiles reproduce the macOS "Cmd" workflow across four layers:

```sh
make macos-keys   # GNOME: GTK Emacs key theme + free <Super>v
make keyd         # keyd: global Cmd layer + per-app profiles (needs sudo)
```

| Layer | What it provides | Where |
|-------|------------------|-------|
| keyd (global) | **Full Cmd behaviour in every app** (Cmd+S/Z/A/F/W/N/O/P/R/T, Cmd+C/V/X, Cmd+←/→, Cmd+Tab) | `keyd/default.conf` |
| keyd (per-app) | Terminal-safe mask for Ghostty (Cmd+T/W/Q/N/F/A/D/K, no Cmd+S/Z footguns) | `keyd/app.conf` |
| GTK key theme | `Ctrl+A/E/K/F/B` text editing in every GTK app (matches macOS text fields) | `scripts/setup-macos-keys.sh` |
| GNOME | Frees `<Super>v` so Cmd+V reaches the terminal | `scripts/setup-macos-keys.sh` |
| Terminal | Cmd+C/V, font zoom, Cmd+←/→/⌫ line editing | `ghostty/.config/ghostty/config` |
| Shell | ZLE fallbacks for raw Super escape sequences | `zsh/config.zsh` |

### How it works

keyd's `[cmd:C]` layer makes **Cmd behave as Ctrl** for every key without an
explicit mapping, so Cmd+S saves, Cmd+Z undoes, Cmd+A selects all, Cmd+W
closes, Cmd+Q quits, etc. Exceptions:

- **Cmd+C/V/X → Ctrl+Insert / Shift+Insert / Shift+Delete**, so copy/paste/cut
  work in both GTK apps and terminals while **Ctrl+C stays SIGINT**.
- Cmd+←/→ → Home/End; Cmd+↑/↓ → Ctrl+Home/End.
- Cmd+Tab → Super+Tab (app switcher); Cmd+` → Alt+F6 (cycle app windows).
- Cmd+M → Super+H (minimise); Cmd+Space → Super+A (app grid).

Tapping Super alone still opens GNOME Activities.

### Trade-offs

Because Super is redefined, GNOME's own Super shortcuts are replaced:
Super+1-9 (dash) becomes Ctrl+1-9 (browser tab switching, macOS-like), and
Super+A/S/N/D/H are gone (Super+A is reachable as Cmd+Space). In the
**terminal**, unmapped Cmd+keys arrive as Ctrl+keys. That is handled by the
per-app profile below.

### Per-app profiles

`keyd/app.conf` is read by `keyd-application-mapper`. When a matching window is
focused it layers a mask over the global rules, so **Ghostty keeps its
terminal-level shortcuts** while every other app gets the full Cmd behaviour:

| Chord | Sends | Action |
|-------|-------|--------|
| Cmd+T | `Ctrl+Shift+T` | new tab |
| Cmd+W | `Ctrl+Shift+W` | close tab |
| Cmd+Q | `Ctrl+Shift+Q` | quit |
| Cmd+N | `Ctrl+Shift+N` | new window |
| Cmd+F | `Ctrl+Shift+F` | search |
| Cmd+A | `Ctrl+Shift+A` | select all |
| Cmd+D | `Ctrl+Shift+O` | split right |
| Cmd+K | `Super+K` | clear screen |
| Cmd+Shift+[ / ] | `Super+Shift+[ / ]` | prev / next tab |
| Cmd+S | — (`noop`) | avoids `Ctrl+S` (XOFF) |
| Cmd+Z | — (`noop`) | avoids `Ctrl+Z` (suspend) |

Window classes are normalised by the mapper (`com.mitchellh.ghostty` →
`com-mitchellh-ghostty`); discover others with `tail -f ~/.config/keyd/app.log`.

**A fresh session is required** after `make keyd`: the `keyd` group membership
and the keyd GNOME extension (auto-patched for your GNOME version) only take
effect on the next login.

If the mapper still logs `Failed to connect to "/var/run/keyd.socket"` after
logging back in, **reboot**. With `KillUserProcesses=no` (the default), a logout
does not restart `user@1000.service` while other user processes exist, so the
new session inherits the old group list. To test without rebooting:

```sh
sudo setfacl -m u:$USER:rw /var/run/keyd.socket   # temporary; lost on keyd restart
```

keyd remaps at the evdev layer, so it works on Wayland. This is why it's used
instead of [Kinto](https://github.com/rbreaves/kinto), whose Linux backend
(xkeysnail) is X11-only.

Revert with:

```sh
./scripts/setup-keyd.sh --revert
./scripts/setup-macos-keys.sh --revert
```

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
