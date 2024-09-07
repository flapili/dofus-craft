{
  description = "Project deps";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, nix-darwin }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        darwin = pkgs.darwin;
      in
      {
        devShell = pkgs.mkShell {
          buildInputs = [
            pkgs.nodejs_20
            pkgs.rustup
            pkgs.libiconv
          ];

          nativeBuildInputs = [
            darwin.apple_sdk.frameworks.WebKit
          ];

          shellHook = ''
            # Configurer Rust via rustup
            rustup toolchain install stable
            rustup default stable

            # Activer Corepack pour gérer les gestionnaires de paquets Node.js
            corepack enable
            pnpm install
          '';
        };
      });
}