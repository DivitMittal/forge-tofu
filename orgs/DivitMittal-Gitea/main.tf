# ---------------------------------------------------------------------------
# Import all existing gitea.com repos into state without destroying them.
# Add repo entries to terranix/orgs/DivitMittal-Gitea.nix, then:
#   terragrunt plan   — preview what will be imported / created
#   terragrunt apply  — import into state
#
# gitea_repository's import ID is "<owner>/<repo>", not just the repo name.
# ---------------------------------------------------------------------------
import {
  for_each = { for k, v in local.repos : k => v if try(v.existing, true) }
  to       = module.repositories.gitea_repository.repos[each.key]
  id       = "${var.gitea_owner}/${each.key}"
}

# ---------------------------------------------------------------------------
# Modules
# ---------------------------------------------------------------------------
module "repositories" {
  source = "../../modules/repositories-gitea"

  repos = local.repos
  owner = var.gitea_owner
}

module "branch_protection" {
  source = "../../modules/branch-protection-gitea"

  owner              = var.gitea_owner
  protected_branches = local.protected_branches
  depends_on         = [module.repositories]
}
