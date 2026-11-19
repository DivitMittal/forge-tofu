output "repo_urls" {
  description = "HTML URLs for all managed repositories."
  value       = { for k, r in gitea_repository.repos : k => r.html_url }
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
