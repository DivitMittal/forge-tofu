variable "codeberg_token" {
  description = "Codeberg (Gitea) API token for the Qezta org. Injected by Terragrunt from CODEBERG_TOKEN_QEZTA or CODEBERG_TOKEN."
  type        = string
  sensitive   = true
}

variable "codeberg_owner" {
  description = "Codeberg username or organisation name that owns these repositories."
  type        = string
}
