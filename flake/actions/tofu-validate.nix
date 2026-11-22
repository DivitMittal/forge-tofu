## `tofu validate` for every org unit against its committed lock file. Needs no
## tokens or state, so it catches provider schema errors on every PR.
## tests/validate-org.py stands in for Terragrunt, whose inputs decrypt secrets.
{common-actions, ...}: let
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
      strategy = {
        fail-fast = false;
        matrix.unit = [
          {
            org = "DivitMittal";
            package = "divitmittal-locals";
          }
          {
            org = "DivitMittal-GitLab";
            package = "divitmittal-gitlab-locals";
          }
          {
            org = "DivitMittal-Codeberg";
            package = "divitmittal-codeberg-locals";
          }
          {
            org = "DivitMittal-Gitea";
            package = "divitmittal-gitea-locals";
          }
          {
            org = "DivitMittal-Sourcehut";
            package = "divitmittal-sourcehut-locals";
          }
        ];
      };
      steps =
        common-actions
        ++ [
          {
            name = "Validate \${{ matrix.unit.org }}";
            run = ''
              set -euo pipefail
              locals="$(nix build --no-link --print-out-paths '.#''${{ matrix.unit.package }}')"
              nix develop -c python3 tests/validate-org.py . '${"$"}{{ matrix.unit.org }}' "$locals" "$RUNNER_TEMP/validate"
            '';
          }
        ];
    };
  };
}
