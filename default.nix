{ nixpkgs ? import <nixpkgs> {},
  haskell-tools ? import (builtins.fetchTarball "https://github.com/danwdart/haskell-tools/archive/master.tar.gz") {
    nixpkgs = nixpkgs;
    compiler = compiler;
  },
  compiler ? "ghc96"
}:
let
  gitignore = nixpkgs.nix-gitignore.gitignoreSourcePure [ ./.gitignore ];
  tools = haskell-tools compiler;
  lib = nixpkgs.pkgs.haskell.lib;
  myHaskellPackages = nixpkgs.pkgs.haskell.packages.${compiler}.override {
    overrides = self: super: rec {
      # not yet uploaded to hackage
      #gedcom = lib.doJailbreak (self.callCabal2nix "gedcom" (nixpkgs.fetchFromGitHub {
      #  owner = "CLowcay";
      #  repo = "hs-gedcom";
      #  rev = "148acdf9664d234d9ec67121448b92d786aa4461";
      #  sha256 = "1v02a9w678zmqa09513j24pkqjva5l3qik9qlyhw4px8fqddnaai";
      #}) {});
      # Atm Nix breaks this.
      family = lib.dontHaddock (self.callCabal2nix "family" (gitignore ./.) {});
    };
  };
  shell = myHaskellPackages.shellFor {
    packages = p: [
      p.family
    ];
    shellHook = ''
      gen-hie > hie.yaml
      for i in $(find -type f | grep -v dist-newstyle); do krank $i; done
    '';
    buildInputs = tools.defaultBuildTools;
    withHoogle = false;
  };
  exe = lib.justStaticExecutables (myHaskellPackages.family);
in
{
  inherit shell;
  family = lib.justStaticExecutables (myHaskellPackages.family);
}
