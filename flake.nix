{
  description = "A Virus, written in Rust, for a school project at EPITECH.";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable"; # Nixpkgs base
    rust-overlay.url = "github:oxalica/rust-overlay"; # Rust overlay for more recent versions
    flake-utils.url = "github:numtide/flake-utils"; # Utilities for multi-system flake (can run on MacOS)
    nixago.url = "github:nix-community/nixago"; # Nixago, to create config files (like .cargo/config.toml)
    nixago.inputs.nixpkgs.follows = "nixpkgs"; # Nixago needs Nixpkgs
  };
  outputs = { self, nixpkgs, rust-overlay, flake-utils, nixago, ... }:
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = import nixpkgs {
            # Import Nixpkgs
            inherit system;
            overlays = [
              rust-overlay.overlays.default
            ];
          };
          systemMapping = {
            # Map Nixpkgs system to Rust target
            "x86_64-linux" = "x86_64-unknown-linux-gnu";
            "x86_64-darwin" = "x86_64-apple-darwin";
            "x86_64-windows" = "x86_64-pc-windows-msvc";
            "aarch64-linux" = "aarch64-unknown-linux-gnu";
            "aarch64-darwin" = "aarch64-apple-darwin";
          };
          myRust = pkgs.rust-bin.stable.latest.default.override {
            # Override Rust targets to include Windows
            extensions = [ "rust-src" ];
            targets = [ systemMapping."${system}" "x86_64-pc-windows-msvc" ];
          };
          xwin = pkgs.callPackage ./xwin.nix {
            # Import xwin (unpacked Windows SDK)
            toolchain = myRust;
          };
          win-libs = pkgs.callPackage ./windows-libs.nix {
            # Import Windows libraries
            inherit xwin;
          };
          linkerConfig = nixago.lib.${system}.make {
            # Configure linker to use Windows SDK
            data = {
              target.x86_64-pc-windows-msvc = {
                linker = "${pkgs.lld}/bin/lld";
                rustflags = [
                  "-Lnative=${win-libs}/lib/crt/lib/x86_64"
                  "-Lnative=${win-libs}/lib/sdk/lib/um/x86_64"
                  "-Lnative=${win-libs}/lib/sdk/lib/ucrt/x86_64"
                ];
              };
            };
            output = ".cargo/config.toml";
            format = "toml";
          };
        in
        rec {
          devShells.default = pkgs.mkShell {
            buildInputs = [
              myRust # Rust, Cargo, etc.
              pkgs.rust-analyzer # Rust analyzer
              pkgs.lld # Linker
              pkgs.wineWowPackages.base # Wine (to locally test Windows builds)
            ];
            shellHook =
              linkerConfig.shellHook + # Configure linker using nixago
              "export RUST_SRC_PATH=${myRust}/lib/rustlib/src/rust/src"; # Configure Rust analyzer
          };

          packages.default = pkgs.rustPlatform.buildRustPackage {
            pname = "virology";
            version = "0.1.0";

            nativeBuildInputs = [ myRust ];

            src = ./.;

            cargoSha256 = "sha256-nSxVfgctOCPZp35B9fwv0i1ul9R9KVo+vF+j4tJqr/A=";
          };


          packages.windows = self.packages.${system}.default.overrideAttrs (oldAttrs: {
            # Override default package to build for Windows

            patchPhase = (oldAttrs.patchPhase or "") + ''
              mkdir -p .cargo
              ln -s ${linkerConfig.configFile} .cargo/config.toml
            '';

            CARGO_BUILD_TARGET = "x86_64-pc-windows-msvc";
          });
        }
      );
}
