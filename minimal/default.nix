{
  pkgs,
  lib,
  ...
}: {
  nix.settings.experimental-features = ["nix-command" "flakes"];

  services = {
    openssh.enable = true;
  };

  networking = {
    useDHCP = lib.mkDefault true;
    wireless.enable = false; # disable wpa_supplicant
    networkmanager.enable = true;
  };

  environment.systemPackages = with pkgs; [
    neovim
    tmux
    # For setting up Yubikey based FDE
    gcc
    yubikey-personalization
    openssl
  ];
}
