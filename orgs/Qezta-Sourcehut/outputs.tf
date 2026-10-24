output "repo_urls" {
  description = "Web URLs for all managed repositories."
  value       = module.repositories.repo_urls
}

output "private_repos" {
  description = "Names of all private repositories."
  value       = module.repositories.private_repos
}

output "repo_count" {
  description = "Total number of managed repositories."
  value       = module.repositories.repo_count
}
