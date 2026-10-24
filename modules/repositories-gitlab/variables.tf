variable "repos" {
  description = "Canonical map of repository names to their configuration. Defined in the org root locals and passed here so root-only import blocks can reference the same map."
  type        = any
}

variable "namespace_id" {
  description = "GitLab group namespace ID that owns these projects. Leave null to create projects under the authenticated user's personal namespace."
  type        = number
  default     = null
}
