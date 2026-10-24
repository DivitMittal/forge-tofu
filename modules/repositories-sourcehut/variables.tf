variable "repos" {
  description = "Canonical map of repository names to their configuration. Defined in the org root locals and passed here so root-only import blocks can reference the same map."
  type        = any
}

variable "owner" {
  description = "SourceHut username (without the leading ~) whose PAT owns these repos. Not sent to the API — sourcehut_repository always creates under the token's own account — used only to compute repo_urls."
  type        = string
}
