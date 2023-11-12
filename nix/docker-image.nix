{ self
, nixpkgs
, release
, hostSystem
, dockerTools
, glibcLocalesUtf8
, coreutils
, ...
}:
let
  hostPkgs = import nixpkgs { system = hostSystem; };

  tag =
    if self ? shortRev then
      "${release.version}-${self.shortRev}"
    else
      throw "Refuse to build docker image from a dirty Git tree.";
in
(dockerTools.override {
  writePython3 = hostPkgs.buildPackages.writers.writePython3;
}).streamLayeredImage {
  name = "registry.fly.io/elixir-china";
  inherit tag;

  contents = [
    dockerTools.caCertificates
    dockerTools.binSh

    coreutils
  ];

  config = {
    Env = [
      "LOCALE_ARCHIVE=${glibcLocalesUtf8}/lib/locale/locale-archive"
      "LANG=en_US.UTF-8"
    ];
    WorkingDir = release;
    Cmd = [ "${release}/bin/server" "start" ];
  };
}
