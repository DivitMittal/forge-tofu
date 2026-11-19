variable "gitea_token" {
  description = "gitea.com API token for the DivitMittal account. Decrypted by Terragrunt from forge/tofu/gitea.age, or taken from GITEA_TOKEN_DIVITMITTAL when set."
  type        = string
  sensitive   = true
}

variable "gitea_owner" {
  description = "gitea.com username or organisation name that owns these repositories."
  type        = string
}
