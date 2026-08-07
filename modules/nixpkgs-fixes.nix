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

        # joblib is in the edk2 env and tests against threadpoolctl, which in
        # turn tests against scipy. hydra only builds the default interpreter,
        # so nothing on this path is cached for 3.12, and scipy's suite fails a
        # hypothesis-generated tolerance case. dropping joblib's tests keeps
        # both out of the closure rather than compiling scipy to ignore it.
        joblib = pyprev.joblib.overridePythonAttrs {doCheck = false;};
      });
    in {
      python312 =
        prev.python312
        // {
          pkgs = pkgs';
          withPackages = f: prev.python312.withPackages (_: f pkgs');
        };
    })

    # jetpack pins uefi-firmware-parser to v1.14, whose setup.py still declares
    # itself uefi_firmware 1.11. nixpkgs-unstable grew a metadata check phase
    # that catches the mismatch, and patchfv stamps the tegra firmware, so the
    # flash script cannot build without it. drop once jetpack converges back to
    # the nixpkgs package, which is on 1.16 and carries the fix it waits for.
    #
    # matched on pname so no other python package's environment moves; patchfv
    # comes from flasherPkgs, hence the top-level set rather than the scope.
    (_: prev: {
      python3Packages =
        prev.python3Packages
        // {
          buildPythonPackage = args:
            prev.python3Packages.buildPythonPackage (
              if builtins.isAttrs args && (args.pname or "") == "uefi-firmware-parser"
              then args // {dontCheckPythonMetadata = true;}
              else args
            );
        };
    })
  ];
}
