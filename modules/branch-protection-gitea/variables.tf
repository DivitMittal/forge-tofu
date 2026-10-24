variable "owner" {
  description = "Gitea/Codeberg username or organisation name that owns these repositories."
  type        = string
}

variable "protected_branches" {
  description = "Map of repo name to branch protection config. Defined per org in generated locals and passed in from the root module."
  type        = map(object({ branch = string }))
}
