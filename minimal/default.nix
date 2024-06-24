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
    openssh = {
      enable = true;
      ports = [22];
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
      };
    };
  };

  networking = {
    useDHCP = lib.mkDefault true;
    wireless.enable = false; # disable wpa_supplicant
    networkmanager.enable = true;
  };

  hardware = {
    gpgSmartcards.enable = true;
  };

  users.users = {
    root = {
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBFPX5biiGhDszrPE8BWvgKz4Ow1etck3E9aacuKXObQ cody@everest"
      ];
    };
  };

  systemd.services.sshd.wantedBy = pkgs.lib.mkForce ["multi-user.target"];

  # Should make build go faster
  isoImage.squashfsCompression = "gzip -Xcompression-level 1";

  environment.systemPackages = with pkgs; [
    neofetch
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
