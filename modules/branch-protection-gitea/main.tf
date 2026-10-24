# ---------------------------------------------------------------------------
# Branch protection rules for all active development repos.
#
# gitea_repository_branch_protection addresses the repo by username+name
# directly rather than a resource ID, so this module only needs `var.owner`
# — no cross-module output from repositories-gitea is required (though it
# should still depend on that module to ensure the repo exists first).
#
# The provider has no dedicated "block force-push only" toggle like GitHub's
# allows_force_pushes: `enable_push = false` blocks all direct pushes
# (including force-pushes) to the matched branch, which is the closest
# equivalent available.
# ---------------------------------------------------------------------------
resource "gitea_repository_branch_protection" "active_repos" {
  for_each = local.protected_branches

  username  = var.owner
  name      = each.key
  rule_name = each.value.branch

  enable_push = false
}
