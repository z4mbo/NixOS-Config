{ pkgs, ... }:

# Tailscale VPN. The tray icon (Tailscale's own `tailscale systray`) shows up in
# Noctalia's tray on the right of the bar: connect/disconnect, exit nodes,
# devices. You're set as operator, so no sudo needed for `tailscale up/down`.
{
  services.tailscale = {
    enable = true;
    openFirewall = true;
    useRoutingFeatures = "client"; # can use exit nodes / subnet routes
    extraSetFlags = [ "--operator=z4mbo" ];
  };

  networking.firewall.trustedInterfaces = [ "tailscale0" ];

  systemd.user.services.tailscale-systray = {
    description = "Tailscale tray icon";
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.tailscale}/bin/tailscale systray";
      Restart = "on-failure";
      RestartSec = 5;
    };
  };
}
