
# Jetson config

NixOS configuration for my NVIDIA Jetson board, focused on reproducibility and easy reinstall.

## Install

```bash
$ sudo loadkeys es
$ nix --no-write-lock-file --extra-experimental-features "nix-command flakes" run github:luisnquin/jetson-config#infection
```
