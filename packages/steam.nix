{ ... }:

{
  programs.steam = {
    enable = true;
    # extest currently injects a preload that is breaking Steam's 32-bit pieces.
    extest.enable = false;
  };
}
