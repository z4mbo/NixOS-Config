{ ... }:

{
  boot.loader = {
    timeout = 5;
    systemd-boot.enable = true;
    grub.enable = false;
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot";
    };
  };
}
