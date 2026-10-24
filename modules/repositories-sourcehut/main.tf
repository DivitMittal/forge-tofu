# ---------------------------------------------------------------------------
# sourcehut_repository has a much smaller surface than the GitHub/GitLab/Gitea
# resources: only `name`, `description`, and `visibility` ("public",
# "unlisted", or "private"). There's no owner/org attribute — a repo always
# belongs to the account that owns the token — no topics, no archived flag,
# no issues/wiki toggles, and no delete-branch-on-merge equivalent. Those
# fields in the shared repo schema are simply ignored here.
# ---------------------------------------------------------------------------
resource "sourcehut_repository" "repos" {
  for_each = local.repos

  name        = each.key
  description = each.value.description
  visibility  = each.value.visibility

  lifecycle {
    # Never let a typo or accidental `terraform destroy` wipe a repo.
    prevent_destroy = true
  }
}

# ---------------------------------------------------------------------------
# Validation: every active repo must have a description.
# Caught at plan time before anything touches the API.
# ---------------------------------------------------------------------------
check "active_repos_have_descriptions" {
  assert {
    condition = alltrue([
      for k, v in local.repos : v.description != null && v.description != ""
    ])
    error_message = "All active repositories must have a non-empty description. Check locals.tf in this module."
  }
}
