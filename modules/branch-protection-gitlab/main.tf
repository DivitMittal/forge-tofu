# ---------------------------------------------------------------------------
# Branch protection rules for all active development repos.
# project is sourced from var.project_ids (passed in from the
# repositories-gitlab module output) to avoid a cross-module resource
# reference.
#
# GitLab's branch protection model doesn't map 1:1 to GitHub's: there's no
# `enforce_admins` / linear-history toggle here, and merge/push access is
# role-based (push_access_level / merge_access_level) rather than a simple
# boolean. `maintainer` is the closest equivalent to "trusted contributors
# only" for a solo/small org.
# ---------------------------------------------------------------------------
resource "gitlab_branch_protection" "active_repos" {
  for_each = local.protected_branches

  project = var.project_ids[each.key]
  branch  = each.value.branch

  push_access_level  = "maintainer"
  merge_access_level = "maintainer"

  # Prevent force-pushes to the default branch.
  allow_force_push = false
}
