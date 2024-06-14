{
  description = "Build custom NixOS installation ISO for x86_64-linux systems";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = {
    self,
    nixpkgs,
  }: let
    installers = {
      minimal = "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix";
    };
  in {
    nixosConfigurations = {
      minimalIso = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          # Load custom configurations as well as everything from the minimal CD
          ./minimal
          installers.minimal
        ];
      };
    };

    packages."x86_64-linux" = {
      minimal = self.nixosConfigurations."minimalIso".config.system.build.isoImage;
      # Helper functions for setting up Yubikey based FDE
      rbtohex = nixpkgs.writeShellScriptBin "rbtohex" ''
        od -An -vtx1 | tr -d ' \n'
      '';
      hextorb = nixpkgs.writeShellScriptBin "hextorb" ''
        tr '[:lower:]' '[:upper:]' | sed -e 's/\([0-9A-F]\{2\}\)/\\\\\\x\1/gI'| xargs printf
      '';
    };
  };
}
