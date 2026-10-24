## Expose terranix-generated Terraform JSON as flake packages.
## Each org's data module lives at `terranix/orgs/<Org>.nix` and compiles to a
## `config.tf.json` derivation. Terragrunt invokes `nix build` for the matching
## package and drops the result next to the org's Terraform files as
## `locals.tf.json` (see `orgs/<Org>/terragrunt.hcl`).
##
## Build manually for inspection:
##   nix build .#divitmittal-locals --print-out-paths | xargs cat | jq
##   nix build .#qezta-locals --print-out-paths | xargs cat | jq
{inputs, ...}: {
  # Pass the perSystem pkgs (nixpkgs-26.05-darwin on x86_64-darwin) rather than
  # `system`, which would make terranix import its own nixpkgs input.
  perSystem = {pkgs, ...}: {
    packages.divitmittal-locals = inputs.terranix.lib.terranixConfiguration {
      inherit pkgs;
      modules = [../terranix/orgs/DivitMittal.nix];
    };

    packages.qezta-locals = inputs.terranix.lib.terranixConfiguration {
      inherit pkgs;
      modules = [../terranix/orgs/Qezta.nix];
    };
  };
}
