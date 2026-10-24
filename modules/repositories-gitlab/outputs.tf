output "project_ids" {
  description = "Map of repo name to GitLab project ID, consumed by the branch-protection-gitlab module."
  value       = { for k, r in gitlab_project.repos : k => r.id }
}

output "repo_urls" {
  description = "Web URLs for all managed projects."
  value       = { for k, r in gitlab_project.repos : k => r.web_url }
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
