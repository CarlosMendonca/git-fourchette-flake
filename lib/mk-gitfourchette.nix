# Builds a single gitfourchette package from one data/gitfourchette.json entry.
#
# gitfourchette is a Python (PyQt6) application built from source with
# buildPythonApplication. Its runtime deps come from nixpkgs, so each release
# needs just one content hash (`srcHash`) for the fetched source tree -- no
# vendorHash. The hash is platform-independent, so this recipe builds on every
# system in `eachDefaultSystem`.
{
  pkgs,
  lib,
  entry,
}:

let
  inherit (entry) version srcHash;
in
pkgs.python3Packages.buildPythonApplication {
  pname = "gitfourchette";
  inherit version;
  pyproject = true;

  src = pkgs.fetchFromGitHub {
    owner = "jorio";
    repo = "gitfourchette";
    rev = "v${version}";
    hash = srcHash;
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
    license = lib.licenses.gpl3Only;
    mainProgram = "gitfourchette";
  };
}
