{ pkgs, ... }:

# WhatsApp: there's no official Linux app, so this is ZapZap, a native Qt
# client around WhatsApp Web (notifications, tray icon, multiple accounts,
# follows the system light/dark theme). Launcher: "ZapZap".
{
  environment.systemPackages = with pkgs; [
    zapzap
  ];
}
