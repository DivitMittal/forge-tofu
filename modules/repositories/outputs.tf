output "node_ids" {
  description = "Map of repo name to GitHub node_id, consumed by the branch-protection module."
  value       = { for k, r in github_repository.repos : k => r.node_id }
}

output "repo_urls" {
  description = "HTML URLs for all managed repositories."
  value       = { for k, r in github_repository.repos : k => r.html_url }
}

output "private_repos" {
  description = "Names of all private repositories."
  value       = [for k, v in local.repos : k if v.visibility == "private"]
}

output "archived_repos" {
  description = "Names of all archived repositories."
  value       = [for k, v in local.repos : k if try(v.archived, false)]
}

output "repo_count" {
  description = "Total number of managed repositories."
  value       = length(local.repos)
}

output "write_workflow_repos" {
  description = "Repos whose GITHUB_TOKEN defaults to write access (should stay short)."
  value       = [for k, r in github_workflow_repository_permissions.repos : k if r.default_workflow_permissions == "write"]
}
