
## Installation methods

### Fast

```sh
$ nixos-install --flake .#jyx # expect the "out of memory" when compiling the linux kernel
$ nixos-install --flake .#jyx --max-jobs 1
```

### Slow

```sh
$ nixos-install --flake .#jyx --max-jobs 1
```

They need a cache layer.
