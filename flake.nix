{
  description = "Extremely simple note-taking app inspired by \"One Big Text File\"";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
  };

  outputs =
    { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      fs = nixpkgs.lib.fileset;
      rustFiles = ./src/main.rs;
      staticFiles = fs.unions [
        ./src/favicon.svg
        ./src/index.html
      ];
      source = fs.unions [
        ./Cargo.toml
        ./Cargo.lock
        staticFiles
        rustFiles
      ];
    in
    {
      nixosModules.textpod =
        {
          config,
          lib,
          pkgs,
          ...
        }:
        import ./textpod.nix {
          inherit config lib pkgs;
          textpod = self.packages.${system}.default;
        };

      packages.${system} = {
        default = pkgs.rustPlatform.buildRustPackage (finalArgs: {
          pname = "textpod";
          version = "0.1.8";
          cargoHash = "sha256-Fe/xynaZF5FWozsjACaxYh4a/0eANBK2CTHrJmrd4eo=";
          src = fs.toSource {
            root = ./.;
            fileset = source;
          };
        });
      };
    };
}
