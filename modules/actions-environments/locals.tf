locals {
  environments = merge(concat([{}], [
    for repo, environments in var.environments : {
      for environment, config in environments : "${repo}:${environment}" => merge(config, {
        repository  = repo
        environment = environment
      })
    }
  ])...)

  environment_secrets = merge(concat([{}], [
    for environment_key, environment in local.environments : {
      for secret_name, source_key in try(environment.secrets, {}) : "${environment_key}:${secret_name}" => {
        repository  = environment.repository
        environment = environment.environment
        secret_name = secret_name
        source_key  = source_key
      }
    }
  ])...)

  environment_variables = merge(concat([{}], [
    for environment_key, environment in local.environments : {
      for variable_name, value in try(environment.variables, {}) : "${environment_key}:${variable_name}" => {
        repository    = environment.repository
        environment   = environment.environment
        variable_name = variable_name
        value         = value
      }
    }
  ])...)

  secret_value_keys = nonsensitive(keys(var.secret_values))

  missing_secret_sources = toset([
    for source_key in distinct([for secret in local.environment_secrets : secret.source_key]) : source_key
    if !contains(local.secret_value_keys, source_key)
  ])

  placeholder_secret_sources = toset([
    for source_key, value in nonsensitive(var.secret_values) : source_key
    if startswith(value, "PLACEHOLDER__MISSING_SECRET__")
  ])
}
