## Terranix data module for the Qezta GitLab namespace.
## Compiled to `locals.tf.json` and consumed by `orgs/Qezta-GitLab/main.tf`
## as `local.repos` and `local.protected_branches`.
##
## Schema (per repo): description, visibility, topics, delete_branch_on_merge.
## Optional: archived, has_issues, existing. See terranix/orgs/DivitMittal-GitLab.nix
## for the full field mapping notes.
##
## Empty scaffold — populate `locals.repos` once real GitLab projects exist
## under this namespace, then run `terragrunt plan` from orgs/Qezta-GitLab.
_: {
  locals.repos = {};

  locals.protected_branches = {};
}
