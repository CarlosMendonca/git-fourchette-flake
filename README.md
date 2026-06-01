# git-fourchette-flake

Nix flake for [gitfourchette](https://gitfourchette.org), the comfortable Git UI by [Iliyas Jorio](https://github.com/jorio).

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

### Use in a NixOS or home-manager configuration

Add the flake as an input. To always follow the latest version:

```nix
inputs.gitfourchette.url = "github:CarlosMendonca/git-fourchette-flake";
```

To pin a specific version:

```nix
inputs.gitfourchette.url = "github:CarlosMendonca/git-fourchette-flake?ref=v1.6.0";
```

To reuse your existing nixpkgs instead of pulling in a separate one:

```nix
inputs.gitfourchette.inputs.nixpkgs.follows = "nixpkgs";
```

Then add the package:

```nix
environment.systemPackages = [ inputs.gitfourchette.packages.${system}.gitfourchette ];
# or in home-manager:
home.packages = [ inputs.gitfourchette.packages.${system}.gitfourchette ];
```

### Build locally

```bash
git clone https://github.com/CarlosMendonca/git-fourchette-flake
cd git-fourchette-flake
nix build
./result/bin/gitfourchette
```

## Current version

gitfourchette [v1.8.0](https://github.com/jorio/gitfourchette/releases/tag/v1.8.0)
