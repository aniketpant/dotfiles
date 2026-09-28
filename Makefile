.PHONY: install clean update setup setup-ubuntu macos-keys keyd fonts

PACKAGES = git zsh starship ghostty opencode pi
BIN_DIR = $(HOME)/bin

install:
	mkdir -p $(BIN_DIR)
	stow -S $(PACKAGES)
	stow -S bin --target=$(BIN_DIR)

clean:
	stow -D $(PACKAGES)
	stow -D bin --target=$(BIN_DIR)

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

