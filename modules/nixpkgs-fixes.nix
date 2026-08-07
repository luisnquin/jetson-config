{...}: {
  nixpkgs.overlays = [
    # pygount 3.2.0 pins chardet<6 while nixpkgs-unstable ships 6.0.0.post1, so
    # its runtime dependency check fails. edk2-pytool-library depends on it and
    # builds the tegra uefi firmware, which makes the flash script unbuildable.
    # drop once nixpkgs relaxes the bound or moves chardet back below 6.
    #
    # kept out of the iso and ori0n on purpose: packageOverrides is an argument
    # to the interpreter derivation, so this changes python312 itself and
    # rebuilds everything that builds with it, the kernel included.
    (_: prev: {
      python312 = prev.python312.override {
        packageOverrides = _: pyprev: {
          pygount = pyprev.pygount.overridePythonAttrs (old: {
            pythonRelaxDeps = (old.pythonRelaxDeps or []) ++ ["chardet"];
          });
        };
      };
    })
  ];
}
