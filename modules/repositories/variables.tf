variable "repos" {
  description = "Canonical map of repository names to their configuration. Defined in the org root locals and passed here so root-only import blocks can reference the same map."
  type        = any
}
