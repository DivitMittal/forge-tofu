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
