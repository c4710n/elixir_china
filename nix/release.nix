{ myEnv, nix-gitignore, ... }:
let
  pname = "elixir_china";
  version = "0.1.0";
  src = nix-gitignore.gitignoreSource [
    "/flake.nix"
    "/flake.lock"
    "/fly.toml"
  ] ../.;

  inherit (myEnv.beamPackages.minimal) fetchMixDeps mixRelease;
  inherit (myEnv.nodePackages) nodejs fetchNpmDeps;

  mixDeps = fetchMixDeps {
    pname = "${pname}-mix-deps";
    inherit version src;
    hash = "sha256-0EK2No9P82iEMH2A3g75lChZaZMdW9K3ecZEmoFyJQs=";
  };

  npmDeps = fetchNpmDeps {
    pname = "${pname}-npm-deps";
    inherit version;
    src = "${src}/assets";
    hash = "sha256-NM6D2PM6V4Oi2Z7O0wP131LGo9dlM2RDk38nlM8mmQQ=";
    postBuild = ''
      # fix broken local packages
      local_packages=(
        "phoenix"
        "phoenix_html"
        "phoenix_live_view"
      )
      for package in ''\${local_packages[@]}; do
        path=node_modules/$package
        if [[ -L $path ]]; then
          echo "fixing local package - $package"
          rm $path
          cp -r ${mixDeps}/$package node_modules/
        fi
      done
    '';
  };
in
mixRelease {
  inherit pname version src;

  mixFodDeps = mixDeps;
  nativeBuildInputs = [ nodejs ];

  removeCookie = false;

  preBuild = ''
    ln -s ${npmDeps}/node_modules assets/node_modules
  '';

  postBuild = ''
    HOME=$(pwd) mix assets.deploy
  '';
}
