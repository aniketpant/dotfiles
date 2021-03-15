# zmodload zsh/zprof  
# shortcut to this dotfiles path is $ZSH
export DOTFILES=$HOME/.dotfiles

# history
setopt hist_ignore_all_dups hist_save_nodups

source "$HOME/.zinit/bin/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Load a few important annexes, without Turbo
# (this is currently required for annexes)
zinit light-mode for \
    BrandonRoehl/zsh-clean

zinit wait lucid for \
    zsh-users/zsh-autosuggestions \
    zdharma/fast-syntax-highlighting \
    zdharma/history-search-multi-word \
    OMZ::plugins/git/git.plugin.zsh \
    OMZ::plugins/autojump/autojump.plugin.zsh \

# source every .zsh file in this repo
for config_file ($DOTFILES/**/*.zsh) source $config_file

# export bin paths
export PATH=$HOME/.local/bin:/usr/local/bin:$PATH
export PATH=$DOTFILES/bin:/usr/local/bin:$PATH

source $HOME/.profile

unsetopt ignoreeof nomatch

# use .localrc for SUPER SECRET CRAP that you don't
# want in your public, versioned repo
if [[ -a $HOME/.localrc ]]
then
  source $HOME/.localrc
fi

if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh/site-functions:$FPATH
  brew analytics off 2>&1 >/dev/null
fi

# load every completion after autocomplete loads
for config_file ($DOTFILES/**/completion.sh)
do
  if test -f $config_file
  then
    source $config_file
  fi
done

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

zstyle ':vcs_info:*' disable-patterns "$HOME/go-code(|/*)"
# zprof
