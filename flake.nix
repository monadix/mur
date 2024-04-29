{
  description = "Myxa's (nix) User Repository";

  nixConfig = {
    extra-substituters = "https://mur.cachix.org";
    extra-trusted-public-keys = "mur.cachix.org-1:VncNRWnvAh+Pl71texI+mPOiwTB5267t029meC4HBC0=";
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; }
      {
        flake = {
          overlays.default = final: prev: import ./overlay.nix final prev;
        };

        systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];
        perSystem = { config, self', inputs', pkgs, system, lib, ... }:
          let
            mur = import ./default.nix { inherit pkgs; };
          in
          {
            packages = lib.filterAttrs (_: v: lib.isDerivation v) mur // {
              default = pkgs.buildEnv {
                name = "mur";
                paths = builtins.attrValues mur;
              };
            };

            devShells.default = pkgs.mkShell {
              buildInputs = [ self'.packages.default ];
            };
          };
      };
}

