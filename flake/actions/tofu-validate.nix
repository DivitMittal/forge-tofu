## `tofu validate` for every org unit against its committed lock file. Needs no
## tokens or state, so it catches provider schema errors on every PR.
## tests/validate-org.py stands in for Terragrunt, whose inputs decrypt secrets.
{
  common-actions,
  lib,
  ...
}: let
  units = {
    DivitMittal = "divitmittal-locals";
    DivitMittal-GitLab = "divitmittal-gitlab-locals";
    DivitMittal-Codeberg = "divitmittal-codeberg-locals";
    DivitMittal-Gitea = "divitmittal-gitea-locals";
    DivitMittal-Sourcehut = "divitmittal-sourcehut-locals";
  };
  paths = [
    "modules/**"
    "orgs/**"
    "terranix/**"
    "root.hcl"
    "flake.lock"
    "tests/validate-org.py"
    "flake/terranix.nix"
    "flake/actions/tofu-validate.nix"
  ];
in {
  flake.actions-nix.workflows.".github/workflows/tofu-validate.yml" = {
    on = {
      pull_request = {inherit paths;};
      push = {
        branches = ["main"];
        inherit paths;
      };
      workflow_dispatch = {};
    };
    jobs.validating-tofu = {
      permissions.contents = "read";
      steps =
        common-actions
        ++ [
          {
            ## One job for all units: a matrix of five Nix jobs trips the
            ## GitHub Actions cache rate limit (magic-nix-cache).
            name = "Validate every org unit";
            run = ''
              set -euo pipefail
              for unit in ${lib.concatStringsSep " " (lib.mapAttrsToList (org: pkg: "${org}:${pkg}") units)}; do
                org="''${unit%%:*}"
                locals="$(nix build --no-link --print-out-paths ".#''${unit#*:}")"
                nix develop -c python3 tests/validate-org.py . "$org" "$locals" "$RUNNER_TEMP/validate-$org"
              done
            '';
          }
        ];
    };
  };
}
