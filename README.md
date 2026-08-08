# jetson-config

NixOS on a Jetson Orin Nano Super devkit, running JetPack 7 (L4T 39.2, kernel 6.8.12).

The installer ISO is cross-compiled from x86_64, so the Jetson never builds it.
The system itself installs to NVMe.

## Requirements

- Jetson Orin Nano devkit. The config is board-specific; for a non-Super board set
  `super = false` in `configuration.nix` and `installer/iso.nix`.
- An NVMe SSD in the M.2 slot. `disko-config.nix` wipes `/dev/nvme0n1` entirely.
- An x86_64 Linux machine with Nix and flakes.
- An SD card or USB stick, 2 GB or larger.
- Ethernet on the Jetson.

## Install

Build the ISO on x86_64:

```
nix build .#packages.x86_64-linux.installer-iso
```

Write it, then verify by reading it back — `dd` succeeding does not mean the card is
sound:

```
sudo dd if=result/iso/*.iso of=/dev/sdX bs=4M oflag=direct conv=fsync status=progress
sync
sudo sh -c 'head -c $(stat -c %s result/iso/*.iso) /dev/sdX' | sha256sum
sha256sum result/iso/*.iso
```

Boot the Jetson from it, then:

```
ssh nixos@nixos.local
infection
```

`infection` runs disko and `nixos-install`. Expect one to two hours: the vendor kernel
and the L4T out-of-tree modules build on the device, since the ISO's copies are
cross-compiled and hash differently.

Reboot and remove the boot medium. If UEFI does not pick the NVMe up on its own, press
ESC during boot and select it in the Boot Manager.

## Notes

`modules/nixpkgs-fixes.nix` patches four Python packages that nixpkgs-unstable
currently ships broken. Without them the JetPack 7 UEFI firmware does not build. Each
patch carries a comment stating the condition under which it can be dropped; check them
when bumping the flake.

The firmware in QSPI and the kernel must share a major JetPack version. If a card does
not boot, the firmware predates it:

```
nix build .#packages.x86_64-linux.flash-firmware
```

Hold FC REC, apply power with USB-C connected to the host, release after two seconds,
confirm `0955:7523` in `lsusb`, then run `result/bin/initrd-flash-*`. Recovery mode is a
SoC ROM path and does not depend on valid firmware, so an interrupted flash is
retryable.

There is no Linux console on HDMI or DP — `/dev/console` is `ttyTCU0`. UEFI does render
there, but once the kernel takes over the only ways in are SSH, the Type-C port
(`jetson.usbDeviceMode.enable`), or a UART adapter.

`cudaSupport` costs nothing here because nothing in the closure consumes CUDA. The first
package that does will build on the device, uncached.
