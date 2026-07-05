# git-fourchette-flake

Nix flake for [gitfourchette](https://gitfourchette.org), the comfortable Git UI by [Iliyas Jorio](https://github.com/jorio).

Every release is exposed as its own package attribute (`gitfourchette_1_6_0`), and `gitfourchette`/`default` always track the newest.

## Usage

### Run without installing

```bash
nix run github:CarlosMendonca/git-fourchette-flake
```

### Try in a temporary shell

```bash
nix shell github:CarlosMendonca/git-fourchette-flake
gitfourchette
```

### Run or install a specific version

Each release is available as `gitfourchette_<version>`, with dots replaced by underscores:

```bash
nix run   github:CarlosMendonca/git-fourchette-flake#gitfourchette_1_6_0
nix shell github:CarlosMendonca/git-fourchette-flake#gitfourchette_1_6_0
nix profile install github:CarlosMendonca/git-fourchette-flake#gitfourchette_1_6_0
```

### Use in a NixOS or home-manager configuration

Add the flake as an input:

```nix
inputs.gitfourchette.url = "github:CarlosMendonca/git-fourchette-flake";
```

To reuse your existing nixpkgs instead of pulling in a separate one:

```nix
inputs.gitfourchette.inputs.nixpkgs.follows = "nixpkgs";
```

Then add a package — either the latest or a pinned version:

```nix
environment.systemPackages = [
  inputs.gitfourchette.packages.${system}.gitfourchette          # newest
  # inputs.gitfourchette.packages.${system}.gitfourchette_1_6_0  # a specific release
];
# or in home-manager:
home.packages = [ inputs.gitfourchette.packages.${system}.gitfourchette ];
```

### As an overlay

Apply `overlays.default` to fold every version into your `pkgs`:

```nix
nixpkgs.overlays = [ inputs.gitfourchette.overlays.default ];
# then, anywhere pkgs is in scope:
environment.systemPackages = [
  pkgs.gitfourchette          # newest
  # pkgs.gitfourchette_1_6_0  # a specific release
];
```

### Legacy version pinning

Older releases remain reachable through git-tag pinning as well:

```nix
inputs.gitfourchette.url = "github:CarlosMendonca/git-fourchette-flake?ref=v1.6.0";
```

### Build locally

```bash
git clone https://github.com/CarlosMendonca/git-fourchette-flake
cd git-fourchette-flake
nix build
./result/bin/gitfourchette
```

## Adding a new release

`data/gitfourchette.json` is the single source of truth. To append the latest upstream release (computing its `srcHash`):

```bash
nix run .#update
```

This runs automatically every month via GitHub Actions.

## Current version

gitfourchette [v1.9.0](https://github.com/jorio/gitfourchette/releases/tag/v1.9.0)
