{ nixpkgs ? import (builtins.fetchTarball "https://github.com/NixOS/nixpkgs/archive/master.tar.gz") {},
  compiler ? "ghc901" }:
let
  gitignore = nixpkgs.nix-gitignore.gitignoreSourcePure [ ./.gitignore ];
  lib = nixpkgs.pkgs.haskell.lib;
  myHaskellPackages = nixpkgs.pkgs.haskell.packages.${compiler}.override {
    overrides = self: super: rec {
      gedcom = self.callCabal2nix "gedcom" (nixpkgs.fetchFromGitHub {
        owner = "CLowcay";
        repo = "hs-gedcom";
        rev = "4c02b68297e41bea94496e8494e647c568fe08ca";
        sha256 = "1v02a9w678zmqa09513j24pkqjva5l3qik9qlyhw4px8fqddnaai";
      }) {};
      family = self.callCabal2nix "family" (gitignore ./.) {};
    };
  };
  shell = myHaskellPackages.shellFor {
    packages = p: [
      p.family
    ];
    shellHook = ''
      gen-hie > hie.yaml
      for i in $(find -type f); do krank $i; done
    '';
    buildInputs = with nixpkgs; with haskellPackages; [
      apply-refact
      cabal-install
      ghcid
      hlint
      implicit-hie
      krank
      stan
      stylish-haskell
      weeder
    ];
    withHoogle = false;
  };
  exe = lib.justStaticExecutables (myHaskellPackages.family);
in
{
  inherit shell;
  inherit exe;
  inherit myHaskellPackages;
  family = myHaskellPackages.family;
}
