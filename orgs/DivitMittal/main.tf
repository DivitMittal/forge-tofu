# ---------------------------------------------------------------------------
# Import all existing repos into state without destroying and re-creating them.
# Requires Terraform >= 1.7 (for_each import blocks).
# Run once: terragrunt plan  — Terraform shows a read-only import plan.
# Then:     terragrunt apply — state is populated, no resources recreated.
# ---------------------------------------------------------------------------
import {
  # Only import repos that pre-existed Terraform. Repos with existing = false
  # are created fresh by Terraform and need no import.
  for_each = { for k, v in local.repos : k => v if try(v.existing, true) }
  to       = module.repositories.github_repository.repos[each.key]
  id       = each.key
}

# ---------------------------------------------------------------------------
# Import existing GitHub Actions environments before managing their secrets.
# ---------------------------------------------------------------------------
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

# ---------------------------------------------------------------------------
# Modules
# ---------------------------------------------------------------------------
module "repositories" {
  source = "../../modules/repositories"
  repos  = local.repos
}

module "actions_environments" {
  source = "../../modules/actions-environments"

  environments  = try(local.actions_environments, {})
  secret_values = var.github_actions_secret_values

  depends_on = [module.repositories]
}

