{ pkgs ? import <nixpkgs> {} }:
pkgs.mkShell {
  packages = with pkgs; [ git direnv nodejs python3 gcc cmake gnumake ];
}
