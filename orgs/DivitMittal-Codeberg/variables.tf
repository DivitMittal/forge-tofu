variable "codeberg_token" {
  description = "Codeberg (Gitea) API token for the DivitMittal account. Decrypted by Terragrunt from forge/tofu/codeberg.age, or taken from CODEBERG_TOKEN_DIVITMITTAL when set."
  type        = string
  sensitive   = true
}

variable "codeberg_owner" {
  description = "Codeberg username or organisation name that owns these repositories."
  type        = string
}
