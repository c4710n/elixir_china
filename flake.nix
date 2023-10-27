{
  description = "A flake for developing and deploying current project.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-npm-buildpackage = {
      url = "github:serokell/nix-npm-buildpackage";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nix-npm-buildpackage }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      overlays = [
        (final: prev: {
          erlang = prev.beam.packages.erlang_25;
          elixir = prev.beam.packages.erlang_25.elixir_1_14;
          nodejs = prev.nodejs_18;
        })
        nix-npm-buildpackage.overlays.default
      ];
      forEachSupportedSystem = f: nixpkgs.lib.genAttrs supportedSystems (system: f {
        pkgs = import nixpkgs { inherit system overlays; };
      });
    in
    {
      devShells = forEachSupportedSystem ({ pkgs }: with pkgs; {
        default = mkShell {
          buildInputs = [
            elixir
            nodejs
          ]
          ++ lib.optionals stdenv.isLinux [
            # For ExUnit notifier
            libnotify

            # for package - file_system
            inotify-tools
          ]
          ++ lib.optionals stdenv.isDarwin [
            # for ExUnit Notifier
            terminal-notifier

            # for package - file_system
            darwin.apple_sdk.frameworks.CoreFoundation
            darwin.apple_sdk.frameworks.CoreServices
          ];

          shellHook = ''
            # limit mix to current project
            mkdir -p .nix-mix
            mkdir -p .nix-hex
            export MIX_HOME=$PWD/.nix-mix
            export HEX_HOME=$PWD/.nix-hex
            export ERL_LIBS=$HEX_HOME/lib/erlang/lib

            # rewire executables
            export PATH=$MIX_HOME/bin:$PATH
            export PATH=$MIX_HOME/escripts:$PATH
            export PATH=$HEX_HOME/bin:$PATH

            # limit history to current project
            export ERL_AFLAGS="-kernel shell_history enabled -kernel shell_history_path '\"$PWD/.erlang-history\"'"
          '';
        };
      });

      packages = forEachSupportedSystem ({ pkgs }:
        with pkgs;
        let
          pname = "elixir_china";
          version = "0.1.0";
          src = nix-gitignore.gitignoreSource [
            "/flake.nix"
            "/flake.lock"
            "/fly.toml"
          ] ./.;
          srcAssets = ./assets;
        in
        rec {
          default = app;
          app =
            let
              mixFodDeps = beamPackages.fetchMixDeps {
                pname = "${pname}-mix-deps";
                inherit src version;
                sha256 = "sha256-N83uiNciSf56Gl0EdVj0vHEiw0yNsKFSqEwG/zYNQC0=";
              };

              npmDeps = (mkNodeModules {
                pname = "${pname}-npm-deps";
                src = srcAssets;
                inherit version;
              }).overrideAttrs (self: {
                buildCommand = self.buildCommand + ''
                  for package in phoenix phoenix_html phoenix_live_view; do
                    rm -rf $out/node_modules/$package
                    cp -r ${mixFodDeps}/$package $out/node_modules/
                  done
                '';
              });
            in
            beamPackages.mixRelease {
              inherit pname version src;
              inherit mixFodDeps;

              nativeBuildInputs = [ nodejs ];

              postBuild = ''
                ln -sf ${npmDeps}/node_modules assets/node_modules
                mix assets.deploy
              '';
            };

          dockerImage = dockerTools.buildLayeredImage {
            name = pname;
            tag = "latest";

            contents = [
              # requirements of mix release scripts
              coreutils
              gnused
              gnugrep
              gawk

              # for healthcheck
              curl
            ] ++ [
              dockerTools.caCertificates
              dockerTools.binSh
            ];

            config = {
              Env = [
                "LANG=en_US.UTF-8"
                "LOCALE_ARCHIVE=${glibcLocalesUtf8}/lib/locale/locale-archive"
                # required by fly.io
                "ECTO_IPV6=true"
                "ERL_AFLAGS='-proto_dist inet6_tcp'"
              ];
              WorkingDir = app;
              Cmd = [ "${app}/bin/server" "start" ];
            };
          };
        });
    };
}
