output "environment_import_ids" {
  description = "Import IDs for existing GitHub repository environments."
  value = {
    for key, environment in local.environments : key => "${environment.repository}:${environment.environment}"
    if try(environment.existing, true)
  }
}

output "environment_count" {
  description = "Total number of managed GitHub Actions environments."
  value       = length(local.environments)
}

output "secret_count" {
  description = "Total number of managed GitHub Actions environment secrets."
  value       = length(local.environment_secrets)
}

output "variable_count" {
  description = "Total number of managed GitHub Actions environment variables."
  value       = length(local.environment_variables)
}

output "pending" {
  description = "Secrets and variables declared per environment but not yet managed."
  value = {
    for key, environment in local.environments : key => {
      secrets   = sort(keys(try(environment.pending_secrets, {})))
      variables = sort(try(environment.pending_variables, []))
    }
    if length(try(environment.pending_secrets, {})) + length(try(environment.pending_variables, [])) > 0
  }
}
