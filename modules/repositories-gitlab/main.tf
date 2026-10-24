resource "gitlab_project" "repos" {
  for_each = local.repos

  name         = each.key
  description  = each.value.description
  namespace_id = var.namespace_id

  visibility_level = each.value.visibility

  issues_access_level = try(each.value.has_issues, true) ? "enabled" : "disabled"
  wiki_access_level   = "disabled" # wikis unused across all personal repos
  archived            = try(each.value.archived, false)

  # Delete merged MR branches automatically — good hygiene for active repos.
  remove_source_branch_after_merge = each.value.delete_branch_on_merge

  topics = try(each.value.topics, [])

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
