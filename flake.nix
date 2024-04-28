{
  description = "Myxa's (nix) User Repository";

  nixConfig = {
    extra-substituters = "https://mur.cachix.org";
    extra-trusted-public-keys = "mur.cachix.org-1:VncNRWnvAh+Pl71texI+mPOiwTB5267t029meC4HBC0=";
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        mup = import ./default.nix { inherit pkgs; };
      in
      {
        packages = nixpkgs.lib.filterAttrs (_: v: nixpkgs.lib.isDerivation v) mup;

        defaultPackage = pkgs.buildEnv {
          name = "mur";
          paths = builtins.attrValues self.packages.${system};
        };

        devShells.default = pkgs.mkShell {
          buildInputs = [ self.defaultPackage.${system} ];
        };
      }
    );
}

