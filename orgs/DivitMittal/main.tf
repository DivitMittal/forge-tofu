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
# Modules
# ---------------------------------------------------------------------------
module "repositories" {
  source = "../../modules/repositories"
  repos  = local.repos
}

