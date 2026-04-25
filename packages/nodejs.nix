{ pkgs, ... }:

{
  # Let npm-installed native binaries use a conventional dynamic loader path.
  programs.nix-ld.enable = true;

  environment.systemPackages = with pkgs; [
    nodejs
  ];
}
