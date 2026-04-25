{ pkgs, ... }:

let
  noctaliaShell =
    (builtins.getFlake
      "github:noctalia-dev/noctalia-shell/d85ad414baffd12ea6cf4c88ae5def8e96ec3753?narHash=sha256-oGMYWsP0qthxQisirZc/r/vpdGTZrInwkh75AC714AE=")
    .packages.${pkgs.stdenv.hostPlatform.system}.default;
in
{
  environment.systemPackages = [
    noctaliaShell
  ];

  hardware.bluetooth.enable = true;
  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;
}
