variable "gitea_token" {
  description = "gitea.com API token for the DivitMittal account. Injected by Terragrunt from GITEA_TOKEN_DIVITMITTAL or GITEA_TOKEN."
  type        = string
  sensitive   = true
}

variable "gitea_owner" {
  description = "gitea.com username or organisation name that owns these repositories."
  type        = string
}
