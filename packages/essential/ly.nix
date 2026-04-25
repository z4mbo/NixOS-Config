{ pkgs, ... }:

let
  lyRosePineMoonTtyColors = pkgs.writeShellScript "ly-rose-pine-moon-tty-colors" ''
    ${pkgs.coreutils}/bin/printf '%b' '\e]P0232136\e]P1eb6f92\e]P23e8fb0\e]P3f6c177\e]P49ccfd8\e]P5c4a7e7\e]P6ea9a97\e]P7e0def4\e]P86e6a86\e]P9eb6f92\e]PA3e8fb0\e]PBf6c177\e]PC9ccfd8\e]PDc4a7e7\e]PEea9a97\e]PFe0def4\ec'
  '';
in
{
  services.displayManager = {
    defaultSession = "niri";
    ly = {
      enable = true;
      x11Support = false;
      settings = {
        full_color = true;
        bg = "0x00232136";
        fg = "0x00E0DEF4";
        border_fg = "0x0056526E";
        error_fg = "0x01EB6F92";
        start_cmd = "${lyRosePineMoonTtyColors}";
        term_reset_cmd = "${pkgs.ncurses}/bin/tput reset; ${lyRosePineMoonTtyColors}";
      };
    };
  };
}
