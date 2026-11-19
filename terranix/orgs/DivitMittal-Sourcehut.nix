## Terranix data module for the DivitMittal SourceHut (sr.ht) account.
## Compiled to `locals.tf.json` and consumed by `orgs/DivitMittal-Sourcehut/main.tf`
## as `local.repos`.
##
## Schema (per repo): description, visibility ("public", "unlisted", or
## "private"). That's the entire sourcehut_repository surface — no topics,
## no archived flag, no delete_branch_on_merge, no has_issues; those fields
## from the other forges' terranix files don't apply here and are ignored by
## modules/repositories-sourcehut if present.
##
## SourceHut has no branch-protection API exposed by the wombelix/sourcehut
## provider, so there's no `locals.protected_branches` here and no
## branch-protection-sourcehut module.
##
## Empty scaffold — populate `locals.repos` once real repos exist under this
## account, then run `terragrunt plan` from orgs/DivitMittal-Sourcehut.
_: {
  locals.repos = {};
}
