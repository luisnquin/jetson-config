#!/usr/bin/env bash

infect() {
	set -eu

	DOTS_DIR="$HOME/.dotfiles"

	if [ -d "$DOTS_DIR/.git" ]; then
		git -C "$DOTS_DIR" pull --ff-only
	else
		git clone https://github.com/luisnquin/jetson-config.git "$DOTS_DIR"
	fi

	cd "$DOTS_DIR" || exit 1
	nix --experimental-features "nix-command flakes" \
		run .#disko -- --mode disko ./disko-config.nix

	if ! nixos-install --flake .#jyx; then
		nixos-install --max-jobs 1 --flake .#jyx
	fi
}

main() {
	sudo bash -c "$(declare -f infect); infect"
}

main
