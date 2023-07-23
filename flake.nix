{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils }: (flake-utils.lib.eachSystem [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" ] (system:
    let
      pkgs = import nixpkgs {
        inherit system;
      };

      fixWrapper = pkgs.runCommand "fix-wrapper" {} ''
        mkdir -p $out/bin
        for i in ${pkgs.gcc.cc}/bin/*-gnu-gcc*; do
          ln -s ${pkgs.gcc}/bin/gcc $out/bin/$(basename "$i")
        done
        for i in ${pkgs.gcc.cc}/bin/*-gnu-{g++,c++}*; do
          ln -s ${pkgs.gcc}/bin/g++ $out/bin/$(basename "$i")
        done
      '';


      fhs = pkgs.buildFHSUserEnv {
        name = "openwrt-env";
        targetPkgs = pkgs: with pkgs; [
          git
          perl
          gnumake
          gcc
          unzip
          util-linux
          python3
          rsync
          patch
          wget
          file
          subversion
          which
          pkg-config
          openssl
          fixWrapper
          systemd
          binutils
          expat

          ncurses
          zlib
          zlib.static
          glibc.static
        ];
        multiPkgs = null;
        extraOutputsToInstall = [ "dev" ];
        profile = ''
          export hardeningDisable=all
        '';
      };
    in
    {
      devShell = fhs.env;
    }));
}
