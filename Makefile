.PHONY: install clean update setup setup-ubuntu macos-keys keyd fonts

install:
	stow -S git zsh bin starship ghostty

clean:
	stow -D git zsh bin starship ghostty

update:
	git pull --rebase

setup: setup-ubuntu

setup-ubuntu:
	./scripts/setup-ubuntu.sh

macos-keys:
	./scripts/setup-macos-keys.sh

keyd:
	./scripts/setup-keyd.sh

fonts:
	install-font fonts/CommitMonoV143.zip CommitMono

