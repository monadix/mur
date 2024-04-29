{ pkgs, packages, overlays, ... }:
let
  art = builtins.readFile ./ascii.art;
  packagesList = pkgs.lib.attrValues packages;
in
with builtins; pkgs.writeScriptBin "mur" ''
  #!/usr/bin/env bash
  cat << "EOF"
  ${art}
  EOF

  echo "
  or mur～
  Packages (${toString (length packagesList)}):
  ${concatStringsSep "\n" (map (p: "${p.pname} (${p.version}): ${if p.meta ? longDescription then p.meta.longDescription else p.meta.description}") packagesList)}
  "''
