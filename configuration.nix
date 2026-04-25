{ lib, ... }:

let
  collectNixModules =
    dir:
    let
      entries = builtins.readDir dir;
      names = builtins.attrNames entries;
    in
    lib.concatMap (
      name:
      let
        kind = entries.${name};
        path = dir + "/${name}";
      in
      if kind == "directory" then
        collectNixModules path
      else if kind == "regular" && lib.hasSuffix ".nix" name then
        [ path ]
      else
        [ ]
    ) names;
in
{
  imports = [
    ./hardware-configuration.nix
  ] ++ collectNixModules ./packages;

  system.stateVersion = "25.11";
}
