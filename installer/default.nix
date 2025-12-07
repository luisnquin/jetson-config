{stdenv}:
stdenv.mkDerivation {
  name = "infection";
  src = ./.;
  installPhase = ''
    mkdir -p $out/bin
    cp infection.sh $out/bin/infection
    chmod +x $out/bin/infection
  '';
}
