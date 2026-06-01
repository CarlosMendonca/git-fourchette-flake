{
  description = "gitfourchette - the comfortable Git UI";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        version = "1.8.0";
      in {
        packages.gitfourchette = pkgs.python3Packages.buildPythonApplication {
          pname = "gitfourchette";
          inherit version;
          pyproject = true;

          src = pkgs.fetchFromGitHub {
            owner = "jorio";
            repo = "gitfourchette";
            rev = "v1.8.0";
            hash = "sha256-GU/Xa9g4DW0npZxNZ4I9vb1ypEqOthSRuZ5Frv4vIrE=";
          };

          nativeBuildInputs = with pkgs.python3Packages; [
            setuptools
            wheel
          ];

          dependencies = with pkgs.python3Packages; [
            pygit2
            pyqt6
            pygments
          ];

          meta = {
            description = "The comfortable Git UI";
            homepage = "https://gitfourchette.org";
            license = pkgs.lib.licenses.gpl3Only;
            mainProgram = "gitfourchette";
          };
        };

        packages.default = self.packages.${system}.gitfourchette;

        apps.gitfourchette = flake-utils.lib.mkApp {
          drv = self.packages.${system}.gitfourchette;
        };
        apps.default = self.apps.${system}.gitfourchette;
      });
}
