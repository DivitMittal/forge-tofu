output "protected_branch_rules" {
  description = "Applied branch protection patterns keyed by repo."
  value       = { for k, r in gitea_repository_branch_protection.active_repos : k => r.rule_name }
}
