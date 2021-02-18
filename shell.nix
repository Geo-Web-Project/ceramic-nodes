{ pkgs ? import <nixpkgs> { } }:
pkgs.mkShell {
  buildInputs = with pkgs; [ nodePackages.node2nix ];
}