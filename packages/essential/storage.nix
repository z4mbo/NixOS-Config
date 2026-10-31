{ ... }:

{
  # Transparent compression on the btrfs root (kept out of the generated
  # hardware-configuration.nix so a regeneration doesn't drop it).
  fileSystems."/".options = [ "compress=zstd" "noatime" ];

  # Compressed swap in RAM as a safety net (there is no swap partition).
  zramSwap.enable = true;
}
