{ pkgs, ... }:

{
  users.users.z4mbo = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" "video" ];
    shell = pkgs.zsh;
  };

  users.users.root.shell = pkgs.zsh;

  security.sudo.extraRules = [
    {
      users = [ "z4mbo" ];
      commands = [
        {
          command = "ALL";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];
}
