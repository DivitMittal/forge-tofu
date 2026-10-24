## Expose terranix-generated Terraform JSON as flake packages.
## Each org's data module lives at `terranix/orgs/<Org>.nix` and compiles to a
## `config.tf.json` derivation. Terragrunt invokes `nix build` for the matching
## package and drops the result next to the org's Terraform files as
## `locals.tf.json` (see `orgs/<Org>/terragrunt.hcl`).
##
## Build manually for inspection:
##   nix build .#divitmittal-locals --print-out-paths | xargs cat | jq
##   nix build .#qezta-locals --print-out-paths | xargs cat | jq
##   nix build .#divitmittal-gitea-locals --print-out-paths | xargs cat | jq
{inputs, ...}: {
  perSystem = {pkgs, ...}: {
    packages.divitmittal-locals = inputs.terranix.lib.terranixConfiguration {
      inherit pkgs;
      modules = [../terranix/orgs/DivitMittal.nix];
    };

    packages.qezta-locals = inputs.terranix.lib.terranixConfiguration {
      inherit pkgs;
      modules = [../terranix/orgs/Qezta.nix];
    };

    packages.divitmittal-gitlab-locals = inputs.terranix.lib.terranixConfiguration {
      inherit pkgs;
      modules = [../terranix/orgs/DivitMittal-GitLab.nix];
    };

    packages.qezta-gitlab-locals = inputs.terranix.lib.terranixConfiguration {
      inherit pkgs;
      modules = [../terranix/orgs/Qezta-GitLab.nix];
    };

    packages.divitmittal-codeberg-locals = inputs.terranix.lib.terranixConfiguration {
      inherit pkgs;
      modules = [../terranix/orgs/DivitMittal-Codeberg.nix];
    };

    packages.qezta-codeberg-locals = inputs.terranix.lib.terranixConfiguration {
      inherit pkgs;
      modules = [../terranix/orgs/Qezta-Codeberg.nix];
    };

    packages.divitmittal-gitea-locals = inputs.terranix.lib.terranixConfiguration {
      inherit pkgs;
      modules = [../terranix/orgs/DivitMittal-Gitea.nix];
    };

    packages.divitmittal-sourcehut-locals = inputs.terranix.lib.terranixConfiguration {
      inherit pkgs;
      modules = [../terranix/orgs/DivitMittal-Sourcehut.nix];
    };

    packages.qezta-sourcehut-locals = inputs.terranix.lib.terranixConfiguration {
      inherit pkgs;
      modules = [../terranix/orgs/Qezta-Sourcehut.nix];
    };
  };
}
