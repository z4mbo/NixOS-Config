{ inputs, lib, pkgs, ... }:

# Hex: local, on-device voice dictation (https://anoma.ly/hex).
#   Super+D        start dictating; press again to transcribe + paste
#   Super+Shift+D  paste the last dictation again
#   Super+Ctrl+D   cancel the current recording
# Runs as a per-user background service (tray icon in the bar). Open its window
# from the launcher ("Hex") for settings, Modes and History. The speech model
# is downloaded once into ~/.local/share/hex.
let
  hex = inputs.hex.packages.${pkgs.stdenv.hostPlatform.system}.default;
  supportDir = "%h/.local/share/hex";

  waitForSession = pkgs.writeShellApplication {
    name = "hex-wait-for-session";
    runtimeInputs = with pkgs; [ coreutils gnugrep xprop ];
    text = builtins.readFile "${inputs.hex}/nix/wait-for-session.sh";
  };

  installModel = pkgs.writeShellApplication {
    name = "hex-install-model";
    runtimeInputs = with pkgs; [ coreutils systemd ];
    text = ''
      for _ in $(seq 60); do
        systemctl --system is-active --quiet network-online.target && break
        sleep 2
      done
      exec ${lib.getExe hex} model install
    '';
  };
in
{
  imports = [ inputs.hex.nixosModules.hex ];

  programs.hex = {
    enable = true;
    package = hex;
  };

  systemd.user.services.hex = {
    description = "Hex local voice dictation";
    after = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    wantedBy = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "notify";
      NotifyAccess = "main";
      ExecStartPre = lib.getExe waitForSession;
      ExecStart = "${lib.getExe hex} service";
      Environment = [ "HEX_APPLICATION_SUPPORT_DIR=${supportDir}" ];
      EnvironmentFile = "-${supportDir}/session.env";
      TimeoutStartSec = 35;
      Restart = "on-failure";
      RestartSec = 5;
      TimeoutStopSec = 30;
      UMask = "0077";
    };
  };

  # Download the speech model in the background (no-op once it's there).
  systemd.user.services.hex-model = {
    description = "Download Hex's transcription model";
    wantedBy = [ "default.target" ];
    serviceConfig = {
      Type = "exec";
      ExecStart = lib.getExe installModel;
      Environment = [ "HEX_APPLICATION_SUPPORT_DIR=${supportDir}" ];
      Restart = "on-failure";
      RestartSec = 60;
      UMask = "0077";
    };
  };
}
