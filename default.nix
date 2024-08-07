{ nixpkgs ? import <nixpkgs> {},
  haskell-tools ? import (builtins.fetchTarball "https://github.com/danwdart/haskell-tools/archive/master.tar.gz") {
    nixpkgs = nixpkgs;
    compiler = compiler;
  },
  compiler ? "ghc94"
}:
let
  gitignore = nixpkgs.nix-gitignore.gitignoreSourcePure [ ./.gitignore ];
  tools = haskell-tools compiler;
  lib = nixpkgs.pkgs.haskell.lib;
  myHaskellPackages = nixpkgs.pkgs.haskell.packages.${compiler}.override {
    overrides = self: super: rec {
      family = lib.dontHaddock (self.callCabal2nix "family" (gitignore ./.) {});
      text-all = lib.doJailbreak (lib.markUnbroken super.text-all);
      # gedcom = lib.doJailbreak (super.gedcom);

      # Release to cabal not yet made
      gedcom = lib.doJailbreak (self.callCabal2nix "gedcom" (nixpkgs.fetchFromGitHub {
        owner = "CLowcay";
        repo = "hs-gedcom";
        rev = "148acdf9664d234d9ec67121448b92d786aa4461";
        sha256 = "Q6bycMXI4a9ZP5J/Cok4WN/ynjoWGybvwWrAy9Za/ag=";
      }) {});
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
  in
{
  inherit shell;
  family = lib.justStaticExecutables (myHaskellPackages.family);
}
