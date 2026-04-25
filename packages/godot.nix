{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    godot_4_6
  ];
}
