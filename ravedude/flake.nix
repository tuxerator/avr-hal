{
  inputs = {
    utils = { url = "github:numtide/flake-utils"; };

    naersk = { url = "github:nix-community/naersk"; };

    nixpkgs-mozilla = {
      url = "github:mozilla/nixpkgs-mozilla";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, nixpkgs-mozilla, utils, naersk }:
    utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;

          overlays = [ (import nixpkgs-mozilla) ];
        };

        toolchain = (pkgs.rustChannelOf {
          rustToolchain = ./rust-toolchain.toml;
          sha256 = "sha256-lMLAupxng4Fd9F1oDw8gx+qA0RuF7ou7xhNU8wgs0PU=";
        }).rust;

        naersk' = pkgs.callPackage naersk {
          cargo = toolchain;
          rustc = toolchain;
        };

        lib = pkgs.lib;

      in rec {
        packages.default = naersk'.buildPackage {
          pname = "ravedude";
          src = ./.;

          buildInputs = with pkgs;
            lib.optionals pkgs.stdenv.isLinux [ pkg-config udev ];
        };
      });
}
