# ---------------------------------------------------------------------------
# Import all existing Qezta repos into state without destroying them.
# Add repo entries to terranix/orgs/Qezta.nix, then:
#   terragrunt plan   — preview what will be imported / created
#   terragrunt apply  — import into state
# ---------------------------------------------------------------------------
import {
  for_each = { for k, v in local.repos : k => v if try(v.existing, true) }
  to       = module.repositories.github_repository.repos[each.key]
  id       = each.key
}

# ---------------------------------------------------------------------------
# Modules
# ---------------------------------------------------------------------------
module "repositories" {
  source = "../../modules/repositories"
  repos  = local.repos
}

module "branch_protection" {
  source             = "../../modules/branch-protection"
  repo_node_ids      = module.repositories.node_ids
  protected_branches = local.protected_branches
}
