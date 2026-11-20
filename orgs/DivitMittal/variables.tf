variable "github_token" {
  description = "GitHub PAT for the DivitMittal org. Injected by Terragrunt from GITHUB_TOKEN_DIVITMITTAL or GITHUB_TOKEN."
  type        = string
  sensitive   = true
}

variable "github_actions_secret_values" {
  description = "Sensitive GitHub Actions secret values keyed by logical source name. Injected by Terragrunt; never commit values."
  type        = map(string)
  sensitive   = true
  default     = {}
}

variable "tofu_state_passphrase" {
  description = "Runtime-decrypted encryption key for this GitHub unit's state and plans."
  type        = string
  sensitive   = true
  nullable    = false
  validation {
    condition     = length(var.tofu_state_passphrase) >= 32
    error_message = "Use a persistent state passphrase of at least 32 characters."
  }
}
