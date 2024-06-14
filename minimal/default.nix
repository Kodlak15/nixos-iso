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
    # disable wpa_supplicant
    wireless.enable = false;
    # enable networkmanager
    networkmanager.enable = true;
  };

  environment.systemPackages = with pkgs; [
    neovim
    tmux
  ];
}
