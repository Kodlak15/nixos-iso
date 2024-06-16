{
  description = "Build custom NixOS installation ISO for x86_64-linux systems";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
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
    };
  };
}
