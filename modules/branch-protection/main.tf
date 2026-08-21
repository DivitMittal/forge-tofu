# ---------------------------------------------------------------------------
# Branch protection rules for all active development repos.
# repository_id is sourced from var.repo_node_ids (passed in from the
# repositories module output) to avoid a cross-module resource reference.
#
# If any protection already exists, import it with:
#   terraform import 'module.branch_protection.github_branch_protection.active_repos["infra-nixCfg"]' infra-nixCfg:master
# ---------------------------------------------------------------------------
resource "github_branch_protection" "active_repos" {
  for_each = local.protected_branches

  repository_id = var.repo_node_ids[each.key]
  pattern       = each.value.branch

  # Don't lock yourself out of your own repos.
  enforce_admins = false

  # Linear history keeps `git log --oneline` readable.
  required_linear_history = true

  # Conversations must be resolved before merging (good practice even solo).
  require_conversation_resolution = true

  # Prevent force-pushes to the default branch.
  # GitHub does not distinguish between --force and --force-with-lease;
  # this blocks both.
  allows_force_pushes = false
  allows_deletions    = false
}
