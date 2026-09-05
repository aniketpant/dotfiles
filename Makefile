.PHONY: install clean update

install:
	stow -S git zsh bin starship

clean:
	stow -D git zsh bin starship

update:
	git pull --rebase
