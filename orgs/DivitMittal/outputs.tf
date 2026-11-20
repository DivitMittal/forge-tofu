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

output "write_workflow_repos" {
  description = "Repos whose GITHUB_TOKEN defaults to write access (should stay short)."
  value       = module.repositories.write_workflow_repos
}

output "actions_environments_pending" {
  description = "Actions secrets/variables declared but awaiting an age file or value."
  value       = module.actions_environments.pending
}
