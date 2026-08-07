{...}: {
  nixpkgs.overlays = [
    # pygount 3.2.0 pins chardet<6 while nixpkgs-unstable ships 6.0.0.post1, so
    # its runtime dependency check fails. edk2-pytool-library depends on it and
    # builds the tegra uefi firmware, which makes the flash script unbuildable.
    # drop once nixpkgs relaxes the bound or moves chardet back below 6.
    #
    # the fix rides on the package set instead of python312.override, because
    # packageOverrides is an argument to the interpreter derivation and moves
    # its store path along with everything built against it. an attribute merge
    # leaves the interpreter untouched, and redirecting withPackages reaches the
    # firmware anyway since stuart.nix builds its env through it.
    (_: prev: let
      pkgs' = prev.python312.pkgs.overrideScope (_: pyprev: {
        pygount = pyprev.pygount.overridePythonAttrs (old: {
          pythonRelaxDeps = (old.pythonRelaxDeps or []) ++ ["chardet"];
        });
      });
    in {
      python312 =
        prev.python312
        // {
          pkgs = pkgs';
          withPackages = f: prev.python312.withPackages (_: f pkgs');
        };
    })
  ];
}
