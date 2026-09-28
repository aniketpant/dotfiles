# From http://dotfiles.org/~_why/.zshrc
#
# NOT WIRED UP. Nothing calls title() and there is no precmd hook, so the window
# title is never set by this file. The title currently comes from Ghostty's
# shell-integration-features=title, which lets starship set it instead. To use
# this instead, add a precmd hook and pass the arguments it reads ($2, $3):
#
#   precmd() { title "$(tr -s '\n' ' ' < $HISTCMD[1])" "$PWD" "$PWD"; }
#
# The original also assigns to `a` without `local`, so it leaks a global.
function title() {
  # escape '%' chars in $1, make nonprintables visible
  local a=${(V)1//\%/\%\%}

  # Truncate command, and join lines.
  a=$(print -Pn "%40>...>$a" | tr -d "\n")

  case $TERM in
  screen)
    print -Pn "\ek$a:$3\e\\" # screen title (in ^A")
    ;;
  xterm*|rxvt)
    print -Pn "\e]2;$2\a" # plain xterm title ($3 for pwd)
    ;;
  esac
}

