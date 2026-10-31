{ pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    trusted-users = [ "root" "z4mbo" ];
    auto-optimise-store = true;
  };

  # Keep exactly two system generations (current + previous), then free the
  # store paths nothing references anymore. Runs at boot and daily.
  systemd.services.prune-generations = {
    description = "Keep only the current and previous NixOS generation";
    wantedBy = [ "multi-user.target" ];
    after = [ "nix-daemon.socket" ];
    startAt = "daily";
    serviceConfig.Type = "oneshot";
    script = ''
      ${pkgs.nix}/bin/nix-env --profile /nix/var/nix/profiles/system --delete-generations +2
      ${pkgs.nix}/bin/nix-collect-garbage
    '';
  };
}
