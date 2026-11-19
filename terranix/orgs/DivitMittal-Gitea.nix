## Terranix data module for the DivitMittal account on gitea.com (Gitea's own
## hosted instance — distinct from Codeberg, which is a separate Gitea
## instance at codeberg.org).
## Compiled to `locals.tf.json` and consumed by `orgs/DivitMittal-Gitea/main.tf`
## as `local.repos` and `local.protected_branches`.
##
## Schema (per repo): description, visibility, delete_branch_on_merge is N/A.
## Optional: archived, has_issues, homepage_url, existing. Same shape as the
## GitHub terranix files (terranix/orgs/DivitMittal.nix), minus `topics` —
## the go-gitea/gitea provider has no topics attribute on gitea_repository,
## so any `topics` entries here would be ignored by modules/repositories-gitea.
##
## Empty scaffold — populate `locals.repos` once real gitea.com repos exist
## under this account, then run `terragrunt plan` from orgs/DivitMittal-Gitea.
_: {
  locals.repos = {};

  locals.protected_branches = {};
}
