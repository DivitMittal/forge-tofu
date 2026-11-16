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
# GitHub Actions token permissions (Settings → Actions → General → Workflow
# permissions). Defaults: read-only GITHUB_TOKEN, but workflows may open PRs,
# which DeterminateSystems/update-flake-lock needs in every repo. Workflows
# that need more must declare `permissions:`; a repo whose workflows rely on
# the old write default sets `workflow_permissions = "write"`.
# Archived repos are read-only on GitHub, so the API rejects changes there.
# Creating this resource just writes the setting; no import is needed.
# ---------------------------------------------------------------------------
resource "github_workflow_repository_permissions" "repos" {
  for_each = { for k, v in local.repos : k => v if !try(v.archived, false) }

  repository                       = github_repository.repos[each.key].name
  default_workflow_permissions     = try(each.value.workflow_permissions, "read")
  can_approve_pull_request_reviews = try(each.value.actions_can_create_prs, true)
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

check "workflow_permissions_are_valid" {
  assert {
    condition = alltrue([
      for k, v in local.repos : contains(["read", "write"], try(v.workflow_permissions, "read"))
    ])
    error_message = "workflow_permissions must be \"read\" or \"write\"."
  }
}
