.PHONY: install clean update setup setup-ubuntu

install:
	stow -S git zsh bin starship

clean:
	stow -D git zsh bin starship

update:
	git pull --rebase

setup: setup-ubuntu

setup-ubuntu:
	./scripts/setup-ubuntu.sh

