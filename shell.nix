{ pkgs ? import <nixpkgs> { } }:

pkgs.mkShell {
  packages = with pkgs; [
    bash
    coreutils
    gawk
    sox
    shellcheck
  ];

  shellHook = ''
    export MIMIR_AUDIO_DIR="$PWD/mimir"
  '';
}
