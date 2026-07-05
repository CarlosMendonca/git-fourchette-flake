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

  nativeBuildInputs = [
    # wrapGAppsHook3 puts GTK's GSettings schemas on the runtime environment.
    # gitfourchette is a Qt app, but Qt's *native* file dialog on a GTK/GNOME
    # desktop loads GTK's file chooser, which aborts at runtime unless the
    # `org.gtk.Settings.FileChooser` schema (from gtk3) is reachable.
    pkgs.wrapGAppsHook3
  ]
  ++ (with pkgs.python3Packages; [
    setuptools
    wheel
  ]);

  buildInputs = [ pkgs.gtk3 ];

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
