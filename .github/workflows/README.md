
# Jetson config

NixOS configuration for my NVIDIA Jetson board, focused on reproducibility and easy reinstall.

## Install

```bash
$ sudo -i
$ git clone https://github.com/luisnquin/jetson-config.git && cd jetson-config
$ nix --experimental-features "nix-command flakes" run github:nix-community/disko -- --mode disko ./disko-config.nix
$ nixos-install --flake .#jyx # if you get an "out of memory" error, add '--max-jobs 1'
```
