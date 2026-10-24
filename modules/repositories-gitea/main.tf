# ---------------------------------------------------------------------------
# The go-gitea/gitea provider has no `topics` attribute on gitea_repository
# (unlike the GitHub/GitLab providers), so `topics` entries in the shared
# repo schema are ignored here.
# ---------------------------------------------------------------------------
resource "gitea_repository" "repos" {
  for_each = local.repos

  username    = var.owner
  name        = each.key
  description = each.value.description
  private     = each.value.visibility == "private"

  has_issues   = try(each.value.has_issues, true)
  has_wiki     = false # wikis unused across all personal repos
  has_projects = false # native project management unused
  archived     = try(each.value.archived, false)

  website = try(each.value.homepage_url, null)

  lifecycle {
    # Never let a typo or accidental `terraform destroy` wipe a repo.
    prevent_destroy = true
  }
}

# ---------------------------------------------------------------------------
# Validation: every active (non-archived) repo must have a description.
# Caught at plan time before anything touches the API.
# ---------------------------------------------------------------------------
check "active_repos_have_descriptions" {
  assert {
    condition = alltrue([
      for k, v in local.repos : v.description != null && v.description != ""
      if !try(v.archived, false)
    ])
    error_message = "All active repositories must have a non-empty description. Check locals.tf in this module."
  }
}
