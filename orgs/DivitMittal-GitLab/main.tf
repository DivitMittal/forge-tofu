# ---------------------------------------------------------------------------
# Import all existing GitLab projects into state without destroying and
# re-creating them. Requires Terraform >= 1.7 (for_each import blocks).
#
# The GitLab provider's import ID is the numeric project ID or its full
# "namespace/path" — not just the project name like GitHub's provider. Once
# `locals.repos` in terranix/orgs/DivitMittal-GitLab.nix is populated with
# real projects, adjust `id` below accordingly before running `terragrunt plan`.
# ---------------------------------------------------------------------------
import {
  for_each = { for k, v in local.repos : k => v if try(v.existing, true) }
  to       = module.repositories.gitlab_project.repos[each.key]
  id       = each.key
}

# ---------------------------------------------------------------------------
# Modules
# ---------------------------------------------------------------------------
module "repositories" {
  source = "../../modules/repositories-gitlab"

  repos        = local.repos
  namespace_id = var.gitlab_namespace_id
}

module "branch_protection" {
  source = "../../modules/branch-protection-gitlab"

  project_ids        = module.repositories.project_ids
  protected_branches = local.protected_branches
  depends_on         = [module.repositories]
}
