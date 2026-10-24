## Terranix data module for the Qezta SourceHut (sr.ht) account.
## Compiled to `locals.tf.json` and consumed by `orgs/Qezta-Sourcehut/main.tf`
## as `local.repos`.
##
## Schema (per repo): description, visibility ("public", "unlisted", or
## "private"). See terranix/orgs/DivitMittal-Sourcehut.nix for the full field
## mapping notes (no topics/archived/has_issues/delete_branch_on_merge, no
## branch protection support).
##
## Empty scaffold — populate `locals.repos` once real repos exist under this
## account, then run `terragrunt plan` from orgs/Qezta-Sourcehut.
_: {
  locals.repos = {};
}
