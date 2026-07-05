{
  description = "gitfourchette - the comfortable Git UI, version-selectable";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    let
      # Single source of truth for every packaged release.
      gitfourchetteData = builtins.fromJSON (builtins.readFile ./data/gitfourchette.json);

      mkPackages =
        pkgs:
        import ./lib/mk-packages.nix {
          inherit pkgs gitfourchetteData;
          lib = pkgs.lib;
        };
    in
    {
      # Fold every gitfourchette_*/gitfourchette package into a consumer's nixpkgs.
      # Build from `prev` (leaf packages that don't reference each other), and drop
      # the `default` alias so consumers don't get a stray `pkgs.default`.
      overlays.default = _final: prev: removeAttrs (mkPackages prev) [ "default" ];
    }
    // flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        # `nix run .#update` appends the newest release to data/gitfourchette.json.
        update = pkgs.writeShellApplication {
          name = "gitfourchette-update";
          runtimeInputs = [
            pkgs.curl
            pkgs.jq
            pkgs.coreutils
            pkgs.gnugrep
            pkgs.nix
          ];
          text = ''exec bash ${./updater/update.sh} "$@"'';
        };
      in
      {
        packages = mkPackages pkgs;

        apps.gitfourchette = flake-utils.lib.mkApp {
          drv = self.packages.${system}.gitfourchette;
        };
        apps.default = self.apps.${system}.gitfourchette;

        apps.update = {
          type = "app";
          program = "${update}/bin/gitfourchette-update";
          meta.description = "Append the newest gitfourchette release to data/gitfourchette.json";
        };

        formatter = pkgs.nixfmt;
      }
    );
}
