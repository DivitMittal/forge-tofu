resource "github_repository" "repos" {
  for_each = local.repos

  name        = each.key
  description = each.value.description
  visibility  = each.value.visibility

  has_issues   = try(each.value.has_issues, true)
  has_wiki     = false # wikis unused across all personal repos
  has_projects = false # GitHub Projects unused
  archived     = try(each.value.archived, false)

  # Delete merged PR branches automatically — good hygiene for active repos.
  delete_branch_on_merge = each.value.delete_branch_on_merge

  topics       = each.value.topics
  homepage_url = try(each.value.homepage_url, null)

  # Enable Dependabot alerts for public repos.
  vulnerability_alerts = each.value.visibility == "public" ? true : false

  lifecycle {
    # Never let a typo or accidental `terraform destroy` wipe a repo.
    prevent_destroy = true

    # GitHub auto-initialises repos; ignore the resulting commit.
    ignore_changes = [auto_init]
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
