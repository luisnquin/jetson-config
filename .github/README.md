
# Jetson config

NixOS configuration for my NVIDIA Jetson board, focused on reproducibility and easy reinstall.

## Install

```bash
$ sudo loadkeys es
$ nix --extra-experimental-features "nix-command flakes" run --no-write-lock-file github:luisnquin/jetson-config#infection
```
