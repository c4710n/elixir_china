{
  description = "A flake for developing and deploying current project.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-22.11";
    flake-utils.url = "github:numtide/flake-utils";
    nix-npm-buildpackage.url = "github:serokell/nix-npm-buildpackage";
  };

  outputs = { self, nixpkgs, flake-utils, nix-npm-buildpackage }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        lib = pkgs.lib;

        erlang = pkgs.beam.packages.erlangR25;
        elixir = erlang.elixir_1_14;
        nodejs = pkgs.nodejs-16_x;

        beamPackages = erlang;
        nodePackages = pkgs.callPackage nix-npm-buildpackage { inherit nodejs; };

        pname = "elixir_china";
        version = "0.1.0";
        src = ./.;
        srcAssets = ./assets;

        fetchMixDeps = attrs: beamPackages.fetchMixDeps ({
          inherit elixir;

          pname = "${pname}-mix-deps";
          inherit src version;
        } // attrs);

        fetchNpmDeps = attrs: nodePackages.mkNodeModules ({
          pname = "${pname}-npm-deps";
          src = srcAssets;
          inherit version;
        } // attrs);

        mkMixRelease = attrs: beamPackages.mixRelease ({
          inherit elixir;

          inherit pname src version;
          nativeBuildInputs = [ nodejs ];
        } // attrs);

        shell = with pkgs; mkShell {
          buildInputs = [
            elixir
            nodejs
          ]
          ++ lib.optionals stdenv.isLinux [
            # For ExUnit Notifier on Linux.
            libnotify

            # For file_system on Linux.
            inotify-tools
          ]
          ++ lib.optionals stdenv.isDarwin [
            # For ExUnit Notifier on macOS.
            terminal-notifier

            # For file_system on macOS.
            darwin.apple_sdk.frameworks.CoreFoundation
            darwin.apple_sdk.frameworks.CoreServices
          ];

          shellHook = ''
            # allows mix to work on the local directory
            mkdir -p .nix-mix
            mkdir -p .nix-hex
            export MIX_HOME=$PWD/.nix-mix
            export HEX_HOME=$PWD/.nix-hex
            export ERL_LIBS=$HEX_HOME/lib/erlang/lib

            # concat PATH
            export PATH=$MIX_HOME/bin:$PATH
            export PATH=$MIX_HOME/escripts:$PATH
            export PATH=$HEX_HOME/bin:$PATH

            # enable history for IEx
            export ERL_AFLAGS="-kernel shell_history enabled"
          '';
        };

        release =
          let
            mixFodDeps = fetchMixDeps {
              sha256 = "sha256-aipc631/WUF39RBQk5V4A0gKoPL7x+NJS6Nux1hbiQ4=";
            };

            npmFodDeps = (fetchNpmDeps { }).overrideAttrs (self: {
              buildCommand = self.buildCommand + ''
                for package in phoenix phoenix_html phoenix_live_view; do
                  rm -f $out/node_modules/$package
                  cp -r ${mixFodDeps}/$package $out/node_modules/
                done
              '';
            });
          in
          mkMixRelease {
            inherit mixFodDeps;

            postBuild = ''
              ln -sf ${npmFodDeps}/node_modules assets/node_modules

              # set HOME env to remove the error about non-writable /homeless-shelter dir
              HOME=$(pwd) mix assets.deploy
            '';
          };
      in
      {
        devShells.default = shell;
        packages.default = release;
      }
    );
}
