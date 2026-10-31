{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    godot # always the newest stable Godot 4.x in nixpkgs
  ];
}
