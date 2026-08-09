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

locals {
  actions_environment_import_ids = merge(concat([{}], [
    for repo, environments in try(local.actions_environments, {}) : {
      for environment, config in environments : "${repo}:${environment}" => "${repo}:${environment}"
      if try(config.existing, true)
    }
  ])...)
}

import {
  for_each = local.actions_environment_import_ids
  to       = module.actions_environments.github_repository_environment.environments[each.key]
  id       = each.value
}

module "actions_environments" {
  source = "../../modules/actions-environments"

  environments  = try(local.actions_environments, {})
  secret_values = var.github_actions_secret_values

  depends_on = [module.repositories]
}

module "branch_protection" {
  source             = "../../modules/branch-protection"
  repo_node_ids      = module.repositories.node_ids
  protected_branches = local.protected_branches
}
