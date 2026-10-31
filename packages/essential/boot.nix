{ ... }:

{
  boot.loader = {
    timeout = 5;
    systemd-boot = {
      enable = true;
      # Only the current and the previous build show up in the boot menu.
      configurationLimit = 2;
    };
    grub.enable = false;
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot";
    };
  };
}
