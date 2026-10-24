# sourcehut_repository exposes no URL attribute, so repo_urls is computed
# by convention rather than read off the resource.
output "repo_urls" {
  description = "Web URLs for all managed repositories, computed by convention (git.sr.ht/~owner/repo)."
  value       = { for k, r in sourcehut_repository.repos : k => "https://git.sr.ht/~${var.owner}/${r.name}" }
}

output "private_repos" {
  description = "Names of all private repositories."
  value       = [for k, v in local.repos : k if v.visibility == "private"]
}

output "repo_count" {
  description = "Total number of managed repositories."
  value       = length(local.repos)
}
