{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    <home-manager/nixos>
  ];

  nixpkgs.config.allowUnfree = true;

  nix.settings = {
    experimental-features = [ "nix-command" ];
    trusted-users = [ "root" "z4mbo" ];
  };
  nix.nixPath = [
    "nixos-config=/etc/nixos/configuration.nix"
    "nixpkgs=/nix/var/nix/profiles/per-user/root/channels/nixos"
    "home-manager=/nix/var/nix/profiles/per-user/root/channels/home-manager"
    "/nix/var/nix/profiles/per-user/root/channels"
  ];

  boot = {
    loader = {
      timeout = 5;  # Show boot menu for 5 seconds
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot";
      };
      systemd-boot.enable = false;  # Disable systemd-boot to use GRUB
      grub = {
        enable = true;
        device = "nodev";
        efiSupport = true;
        useOSProber = true;
        configurationLimit = 3;
        efiInstallAsRemovable = false;  # Install to EFI partition
        default = "saved";  # Remember last boot choice
      };
    };

    kernelPackages = pkgs.linuxPackages_6_12;

    initrd.kernelModules = [ ];
    kernelParams = [ ];
  };

  # swapDevices removed - already defined in hardware-configuration.nix

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  services.xserver.videoDrivers = [ "vmware" ];
  virtualisation.vmware.guest.enable = true;

  programs.niri.enable = true;
  programs.steam.enable = true;
  programs.gamemode.enable = true;
  services.displayManager.ly.enable = true;

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    WGPU_BACKEND = "vulkan";
  };

  networking = {
    hostName = "nixos";
    networkmanager.enable = true;
  };

  time.timeZone = "Europe/Rome";
  i18n.defaultLocale = "en_US.UTF-8";

  services.xserver.xkb.layout = "it";
  console.keyMap = "it2";

  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  virtualisation.docker.enable = true;

  users.users.z4mbo = {
    isNormalUser = true;
    description = "Alessandro Zambon";
    extraGroups = [ "networkmanager" "wheel" "video" "docker" ];
    shell = pkgs.zsh;
  };

  users.users.root.shell = pkgs.zsh;

  programs.zsh = {
    enable = true;

    shellAliases = {
      ll = "ls -alF";
      la = "ls -A";
      l = "ls -CF";
    };

    interactiveShellInit = ''
      if [[ $EUID -eq 0 ]]; then
        POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(os_icon dir user)
        POWERLEVEL9K_OS_ICON_BACKGROUND="red"
        POWERLEVEL9K_LEFT_SEGMENT_SEPARATOR=""
        POWERLEVEL9K_RIGHT_SEGMENT_SEPARATOR=""
      else
        POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(os_icon dir vcs user prompt_char)
        POWERLEVEL9K_OS_ICON_BACKGROUND="none"
        POWERLEVEL9K_DIR_VISUAL_IDENTIFIER_EXPANSION=
        POWERLEVEL9K_DIR_FOREGROUND='blue'
        POWERLEVEL9K_VCS_BACKGROUND="none"
        POWERLEVEL9K_VCS_FOREGROUND='#FFA500'
        POWERLEVEL9K_USER_BACKGROUND="none"
        POWERLEVEL9K_USER_FOREGROUND='white'
        POWERLEVEL9K_PROMPT_CHAR_OK_VIINS_CONTENT_EXPANSION='~'
        POWERLEVEL9K_PROMPT_CHAR_ERROR_VIINS_CONTENT_EXPANSION='~'
        POWERLEVEL9K_PROMPT_CHAR_OK_VIINS_FOREGROUND='white'
        POWERLEVEL9K_PROMPT_CHAR_ERROR_VIINS_FOREGROUND='white'
        POWERLEVEL9K_PROMPT_CHAR_BACKGROUND='none'
        POWERLEVEL9K_USER_RIGHT_PADDING=1
      fi

      POWERLEVEL9K_BACKGROUND=
      POWERLEVEL9K_LEFT_LEFT_WHITESPACE=
      POWERLEVEL9K_LEFT_RIGHT_WHITESPACE=
      POWERLEVEL9K_RIGHT_LEFT_WHITESPACE=
      POWERLEVEL9K_RIGHT_RIGHT_WHITESPACE=
      POWERLEVEL9K_LEFT_SEGMENT_SEPARATOR=""
      POWERLEVEL9K_RIGHT_SEGMENT_SEPARATOR=""
      POWERLEVEL9K_LEFT_SUBSEGMENT_SEPARATOR=" "
      POWERLEVEL9K_RIGHT_SUBSEGMENT_SEPARATOR=" "
      POWERLEVEL9K_ICON_BEFORE_CONTENT=true
      POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(background_jobs)
      POWERLEVEL9K_MODE="nerdfont-v3"

      source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
      [[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh
    '';

    ohMyZsh = {
      enable = true;
      plugins = [ "git" ];
    };
  };

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

  environment.systemPackages = with pkgs; [
    # Editors
    vim
    helix
    zed-editor

    # Core tools
    git
    tmux
    btop
    efibootmgr
    os-prober

    # Wayland/VMware
    egl-wayland
    xwayland-satellite
    wl-clipboard
    grim
    slurp
    swaybg
    pwvucontrol

    # Networking
    networkmanagerapplet

    # AI tools
    opencode
    # Fun
    fastfetch

    # Apps
    google-chrome
    discord
    ghostty
    blender
    godot_4
    noctalia-shell
    quickshell
    brightnessctl
    imagemagick
    rofi
    nautilus
    swaynotificationcenter

    # Dev tools
    ripgrep
    fd
    unzip
    gcc
    nodejs
    python3
    curl
    gh
    pciutils
    vulkan-tools
    gamescope
    mangohud
    gamemode

  ];

  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gnome
      pkgs.xdg-desktop-portal-gtk
    ];
    config.common.default = [ "gnome" "gtk" ];
  };

  security.sudo.extraRules = [
    {
      users = [ "z4mbo" ];
      commands = [
        {
          command = "ALL";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  home-manager.users.z4mbo = import ./home.nix;
  home-manager.users.root = { ... }: {
    home.username = "root";
    home.homeDirectory = "/root";
    home.stateVersion = "25.11";
    home.enableNixpkgsReleaseCheck = false;
    programs.home-manager.enable = true;
  };
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.backupFileExtension = "backup";

  system.stateVersion = "25.11";
}
