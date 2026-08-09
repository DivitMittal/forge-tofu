variable "github_token" {
  description = "GitHub PAT for the Qezta org. Injected by Terragrunt from GITHUB_TOKEN_QEZTA or GITHUB_TOKEN."
  type        = string
  sensitive   = true
}

variable "github_actions_secret_values" {
  description = "Sensitive GitHub Actions secret values keyed by logical source name. Injected by Terragrunt; never commit values."
  type        = map(string)
  sensitive   = true
  default     = {}
}
