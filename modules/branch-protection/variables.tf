variable "repo_node_ids" {
  description = "Map of repository name to GitHub node_id. Provided by the repositories module output."
  type        = map(string)
}

variable "protected_branches" {
  description = "Map of repo name to branch protection config. Defined per org in generated locals and passed in from the root module."
  type        = map(object({ branch = string }))
}
