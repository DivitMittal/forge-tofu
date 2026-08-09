resource "github_repository_environment" "environments" {
  for_each = local.environments

  repository  = each.value.repository
  environment = each.value.environment

  can_admins_bypass   = try(each.value.can_admins_bypass, true)
  prevent_self_review = try(each.value.prevent_self_review, false)
  wait_timer          = try(each.value.wait_timer, null)

  dynamic "deployment_branch_policy" {
    for_each = try(each.value.deployment_branch_policy, null) == null ? [] : [each.value.deployment_branch_policy]

    content {
      protected_branches     = deployment_branch_policy.value.protected_branches
      custom_branch_policies = deployment_branch_policy.value.custom_branch_policies
    }
  }
}

resource "github_actions_environment_secret" "secrets" {
  for_each = local.environment_secrets

  repository      = each.value.repository
  environment     = github_repository_environment.environments["${each.value.repository}:${each.value.environment}"].environment
  secret_name     = each.value.secret_name
  plaintext_value = var.secret_values[each.value.source_key]

  lifecycle {
    precondition {
      condition     = !startswith(nonsensitive(var.secret_values[each.value.source_key]), "PLACEHOLDER__MISSING_SECRET__")
      error_message = "Refusing to manage GitHub Actions secret ${each.value.secret_name} with placeholder source ${each.value.source_key}. Decrypt the real value before planning or applying."
    }
  }
}

resource "github_actions_environment_variable" "variables" {
  for_each = local.environment_variables

  repository    = each.value.repository
  environment   = github_repository_environment.environments["${each.value.repository}:${each.value.environment}"].environment
  variable_name = each.value.variable_name
  value         = each.value.value
}

check "all_environment_secret_sources_are_defined" {
  assert {
    condition     = length(local.missing_secret_sources) == 0
    error_message = "Missing GitHub Actions secret source values: ${join(", ", sort(tolist(local.missing_secret_sources)))}. Add them to github_actions_secret_values."
  }
}

check "no_environment_secret_placeholders" {
  assert {
    condition     = length(local.placeholder_secret_sources) == 0
    error_message = "Refusing to manage GitHub Actions secrets with placeholder values for sources: ${join(", ", sort(tolist(local.placeholder_secret_sources)))}. Decrypt the real values before planning or applying."
  }
}
