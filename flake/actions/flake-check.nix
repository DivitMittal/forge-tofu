{
  common-on,
  common-permissions,
  common-actions,
  ...
}: {
  flake.actions-nix.workflows.".github/workflows/flake-check.yml" = {
    on = common-on;
    jobs.checking-flake = {
      permissions = common-permissions;
      steps =
        common-actions
        ++ [
          {
            name = "Evaluate flake for all systems";
            run = "nix -vL flake check --impure --all-systems --no-build";
          }
          {
            # --no-build above only evaluates; this runs org-data,
            # github-state-encryption and the pre-commit hooks.
            name = "Build checks";
            run = "nix -L flake check --impure";
          }
        ];
    };
  };
}
