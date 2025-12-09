#!/bin/sh

infect() {
	DOTS_DIR="$HOME/.dotfiles"
	git clone https://github.com/luisnquin/jetson-config.git "$DOTS_DIR"

	cd "$DOTS_DIR"
	nix --experimental-features "nix-command flakes" \
		run github:nix-community/disko -- --mode disko ./disko-config.nix

	if ! nixos-install --flake .#jyx; then
		nixos-install --max-jobs 1 --flake .#jyx
	fi
}

main() {
	sudo -i
	infect
}

main
