output "repo_urls" {
  description = "HTML URLs for all managed repositories."
  value       = module.repositories.repo_urls
}

output "private_repos" {
  description = "Names of all private repositories."
  value       = module.repositories.private_repos
}

output "archived_repos" {
  description = "Names of all archived repositories."
  value       = module.repositories.archived_repos
}

output "repo_count" {
  description = "Total number of managed repositories."
  value       = module.repositories.repo_count
}
