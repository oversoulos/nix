# Template for per-project flakes
{
  description = "My project flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells.default = import ./devenv-shell.nix { inherit pkgs; };
        
        # Add your project outputs here
        packages.default = pkgs.stdenv.mkDerivation {
          name = "my-project";
          src = ./.;
          installPhase = ''
            mkdir -p $out/bin
            # Build and install your project
          '';
        };
      });
}
