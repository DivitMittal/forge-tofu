## Expose terranix-generated Terraform JSON as flake packages.
## Each org's data module lives at `terranix/orgs/<Org>.nix` and compiles to a
## `config.tf.json` derivation. Terragrunt invokes `nix build` for the matching
## package and drops the result next to the org's Terraform files as
## `locals.tf.json` (see `orgs/<Org>/terragrunt.hcl`).
##
## Build manually for inspection:
##   nix build .#divitmittal-locals --print-out-paths | xargs cat | jq
{inputs, ...}: {
  perSystem = {system, ...}: {
    packages.divitmittal-locals = inputs.terranix.lib.terranixConfiguration {
      inherit system;
      modules = [../terranix/orgs/DivitMittal.nix];
    };
  };
}
