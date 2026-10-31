{ pkgs, ... }:

# Oh My Pi (`omp`): terminal coding agent with multi-model support.
{
  environment.systemPackages = with pkgs; [
    omp
  ];
}
