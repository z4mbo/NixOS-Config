{ pkgs, ... }:

{
  users.users.z4mbo = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" "video" "gamemode" ];
    shell = pkgs.fish;
  };

  # Passwordless sudo so AI agents can rebuild without prompting.
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
