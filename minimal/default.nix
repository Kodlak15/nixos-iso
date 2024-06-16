{
  pkgs,
  lib,
  ...
}: let
  rbtohex =
    pkgs.writeShellScriptBin
    "rbtohex"
    ''( od -An -vtx1 | tr -d ' \n' )'';
  hextorb =
    pkgs.writeShellScriptBin
    "hextorb"
    ''( tr '[:lower:]' '[:upper:]' | sed -e 's/\([0-9A-F]\{2\}\)/\\\\\\x\1/gI'| xargs printf )'';
  pbkdf2Sha512 = pkgs.callPackage ./pbkdf2-sha512.nix {};
in {
  nix.settings.experimental-features = ["nix-command" "flakes"];

  services = {
    openssh.enable = true;
  };

  networking = {
    useDHCP = lib.mkDefault true;
    wireless.enable = false; # disable wpa_supplicant
    networkmanager.enable = true;
  };

  hardware = {
    gpgSmartcards.enable = true;
  };

  environment.systemPackages = with pkgs; [
    neovim
    tmux
    # For setting up Yubikey based FDE
    gcc
    yubikey-personalization
    openssl
    rbtohex
    hextorb
    pbkdf2Sha512
  ];
}
