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

output "protected_branch_rules" {
  description = "Applied branch protection patterns keyed by repo."
  value       = module.branch_protection.protected_branch_rules
}

output "repo_count" {
  description = "Total number of managed repositories."
  value       = module.repositories.repo_count
}

output "write_workflow_repos" {
  description = "Repos whose GITHUB_TOKEN defaults to write access (should stay short)."
  value       = module.repositories.write_workflow_repos
}
