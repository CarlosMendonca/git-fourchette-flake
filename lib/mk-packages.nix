# Builds the full attrset of gitfourchette packages for `pkgs`' own system: one
# `gitfourchette_<version>` per release, plus a `gitfourchette` alias for the
# newest and a `default`. Shared by `packages.<system>` and `overlays.default` so
# the two can never drift apart.
{
  pkgs,
  lib,
  gitfourchetteData,
}:

let
  sanitize = import ./sanitize.nix;

  mkGitfourchette = entry: import ./mk-gitfourchette.nix { inherit pkgs lib entry; };

  # `gitfourchette_<sanitized version>` for every release.
  named = lib.listToAttrs (
    map (e: {
      name = "gitfourchette_${sanitize e.version}";
      value = mkGitfourchette e;
    }) gitfourchetteData
  );

  # Highest version in the data set (null if the list is somehow empty).
  latest =
    if gitfourchetteData == [ ] then
      null
    else
      lib.foldl' (
        acc: e: if builtins.compareVersions e.version acc.version > 0 then e else acc
      ) (builtins.head gitfourchetteData) gitfourchetteData;
in
named
# `gitfourchette` -> newest release; `default` so a plain `nix run`/`nix build` works.
// lib.optionalAttrs (latest != null) {
  gitfourchette = mkGitfourchette latest;
  default = mkGitfourchette latest;
}
