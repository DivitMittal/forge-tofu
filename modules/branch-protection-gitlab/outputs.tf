output "protected_branch_rules" {
  description = "Applied branch protection patterns keyed by repo."
  value       = { for k, r in gitlab_branch_protection.active_repos : k => r.branch }
}
