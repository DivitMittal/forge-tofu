variable "gitlab_token" {
  description = "GitLab PAT for the DivitMittal namespace. Injected by Terragrunt from GITLAB_TOKEN_DIVITMITTAL or GITLAB_TOKEN."
  type        = string
  sensitive   = true
}

variable "gitlab_namespace_id" {
  description = "GitLab group namespace ID that owns these projects. Leave null to create projects under the authenticated user's personal namespace."
  type        = number
  default     = null
}
