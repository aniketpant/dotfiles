# All your dotfiles are belong to us

Orginally, I had taken my dotfiles from [@holman](https://github.com/holman). Eventually I tweaked them a lot and realized that the base configuration didn't work well for me.
After, a while I realized that [@parkr](https://github.com/@parkr) had put his dotfiles up too and these were closer to mine. What you see here is a stripped down version of many dotfiles from GitHub.

## Install

1. Clone this repo
2. `cd` into the directory
3. Run `rake install`

## Components

Taken from @holman's, there are a few special files in the repository:

* `bin/`, anything in `bin/` will get added to your `$PATH` and made available everywhere
* `<topic>/*.zsh`, any files ending with `.zsh` will get loaded into your environment
* `<topic>/*.symlink`, any files ending with `.symlink` will get symlinked into your `$HOME`. This is so you can keep all of those versioned in your dotfiles but still keep those autoloaded in your home directory. These get symlinked when you run `rake install`
* `<topic>/*.completion.sh`, any files ended in `completion.sh` get loaded last so that they get loaded after we set up zsh autocomplete functions

## Thank you people

A special thanks to the awesome folks at Square who put up [their dotfiles](https://github.com/square/maximum-awesome).
