variable "environments" {
  description = "Map of repository name to GitHub Actions environment definitions."
  type = map(map(object({
    existing            = optional(bool, true)
    can_admins_bypass   = optional(bool, true)
    prevent_self_review = optional(bool, false)
    wait_timer          = optional(number)
    deployment_branch_policy = optional(object({
      protected_branches     = bool
      custom_branch_policies = bool
    }))
    secrets   = optional(map(string), {})
    variables = optional(map(string), {})
  })))
  default = {}
}

variable "secret_values" {
  description = "Sensitive GitHub Actions secret values keyed by logical source key."
  type        = map(string)
  sensitive   = true
  default     = {}
}
