## Terranix data module for the DivitMittal GitLab namespace.
## Compiled to `locals.tf.json` and consumed by `orgs/DivitMittal-GitLab/main.tf`
## as `local.repos` and `local.protected_branches`.
##
## Schema (per repo): description, visibility, topics, delete_branch_on_merge.
## Optional: archived, has_issues, existing. Same shape as the GitHub terranix
## files (terranix/orgs/DivitMittal.nix) — `visibility` accepts "public",
## "private", or GitLab's "internal"; `topics` and `delete_branch_on_merge`
## map onto gitlab_project's `topics` and `remove_source_branch_after_merge`.
##
## Empty scaffold — populate `locals.repos` once real GitLab projects exist
## under this namespace, then run `terragrunt plan` from orgs/DivitMittal-GitLab.
_: {
  locals.repos = {};

  locals.protected_branches = {};
}
