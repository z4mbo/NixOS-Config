{ pkgs, ... }:

# Unity Hub: sign in, then install editor versions from inside the Hub.
{
  environment.systemPackages = with pkgs; [
    unityhub
  ];
}
