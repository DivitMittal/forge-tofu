# ---------------------------------------------------------------------------
# Import all existing Codeberg repos into state without destroying them.
# Add repo entries to terranix/orgs/Qezta-Codeberg.nix, then:
#   terragrunt plan   — preview what will be imported / created
#   terragrunt apply  — import into state
#
# gitea_repository's import ID is "<owner>/<repo>", not just the repo name.
# ---------------------------------------------------------------------------
import {
  for_each = { for k, v in local.repos : k => v if try(v.existing, true) }
  to       = module.repositories.gitea_repository.repos[each.key]
  id       = "${var.codeberg_owner}/${each.key}"
}

# ---------------------------------------------------------------------------
# Modules
# ---------------------------------------------------------------------------
module "repositories" {
  source = "../../modules/repositories-gitea"

  repos = local.repos
  owner = var.codeberg_owner
}

module "branch_protection" {
  source = "../../modules/branch-protection-gitea"

  owner              = var.codeberg_owner
  protected_branches = local.protected_branches
  depends_on         = [module.repositories]
}
