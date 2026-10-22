{
  description = "{project-name} flake";

  outputs = inputs: let
    inherit (inputs.flake-parts.lib) mkFlake;
  in
    mkFlake {inherit inputs;} ({inputs, ...}: {
      systems = import inputs.systems;
      imports = [(inputs.import-tree ./flake)];
      perSystem = {system, ...}: {
        # nixpkgs-unstable (26.11+) no longer evaluates on Intel Macs, so pin
        # them to the last nixpkgs branch that still supports x86_64-darwin.
        _module.args.pkgs =
          import (
            if system == "x86_64-darwin"
            then inputs."nixpkgs-2605"
            else inputs.nixpkgs
          ) {
            inherit system;
            config.allowUnfree = true; ## Terraform is BSL Licensed
          };
      };
    });

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    "nixpkgs-2605".url = "github:NixOS/nixpkgs/nixpkgs-26.05-darwin";
    import-tree.url = "github:vic/import-tree";
    agenix.url = "github:ryantm/agenix";
    flake-parts.url = "github:hercules-ci/flake-parts";
    # nix-systems/default dropped x86_64-darwin in c29398b5; pin the last
    # revision that still lists it so lock bumps keep x86_64-darwin outputs.
    systems.url = "github:nix-systems/default/da67096a3b9bf56a91d16901293e51ba5b49a27e";
    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    actions-nix = {
      url = "github:nialov/actions.nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
        git-hooks.follows = "git-hooks";
      };
    };
    terranix = {
      url = "github:terranix/terranix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        systems.follows = "systems";
      };
    };
  };
}
