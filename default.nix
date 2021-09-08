{ nixpkgs ? import (builtins.fetchTarball "https://github.com/NixOS/nixpkgs/archive/master.tar.gz") {},
  compiler ? "ghc8107" }:
let
  gitignore = nixpkgs.nix-gitignore.gitignoreSourcePure [ ./.gitignore ];
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
    buildInputs = [
      nixpkgs.haskellPackages.cabal-install
      nixpkgs.wget
      nixpkgs.haskellPackages.ghcid
      nixpkgs.haskellPackages.stylish-haskell
      nixpkgs.haskellPackages.hlint
    ];
    withHoogle = false;
  };
  exe = nixpkgs.haskell.lib.justStaticExecutables (myHaskellPackages.family);
in
{
  inherit shell;
  inherit exe;
  inherit myHaskellPackages;
  family = myHaskellPackages.family;
}
