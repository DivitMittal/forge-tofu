# ---------------------------------------------------------------------------
# Import all existing SourceHut repos into state without destroying them.
# Add repo entries to terranix/orgs/DivitMittal-Sourcehut.nix, then:
#   terragrunt plan   — preview what will be imported / created
#   terragrunt apply  — import into state
#
# sourcehut_repository's import ID is just the repo name (repos always
# belong to the token's own account — there's no owner prefix like Gitea's).
#
# There's no branch-protection module here: the wombelix/sourcehut provider
# doesn't expose a branch-protection resource, so there's nothing to wire up.
# ---------------------------------------------------------------------------
import {
  for_each = { for k, v in local.repos : k => v if try(v.existing, true) }
  to       = module.repositories.sourcehut_repository.repos[each.key]
  id       = each.key
}

# ---------------------------------------------------------------------------
# Modules
# ---------------------------------------------------------------------------
module "repositories" {
  source = "../../modules/repositories-sourcehut"

  repos = local.repos
  owner = var.sourcehut_owner
}
