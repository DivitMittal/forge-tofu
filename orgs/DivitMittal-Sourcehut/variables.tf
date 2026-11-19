variable "sourcehut_token" {
  description = "SourceHut OAuth2 PAT for the DivitMittal account. Decrypted by Terragrunt from forge/tofu/sourcehut.age, or taken from SOURCEHUT_TOKEN_DIVITMITTAL when set."
  type        = string
  sensitive   = true
}

variable "sourcehut_owner" {
  description = "SourceHut username (without the leading ~) that owns sourcehut_token. Used only to compute repo_urls."
  type        = string
}
