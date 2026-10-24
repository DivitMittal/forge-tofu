## Terranix data module for the Qezta Codeberg organisation.
## Compiled to `locals.tf.json` and consumed by `orgs/Qezta-Codeberg/main.tf`
## as `local.repos` and `local.protected_branches`.
##
## Schema (per repo): description, visibility. Optional: archived, has_issues,
## homepage_url, existing. See terranix/orgs/DivitMittal-Codeberg.nix for the
## full field mapping notes (no `topics` support on this provider).
##
## Empty scaffold — populate `locals.repos` once real Codeberg repos exist
## under this org, then run `terragrunt plan` from orgs/Qezta-Codeberg.
_: {
  locals.repos = {};

  locals.protected_branches = {};
}
