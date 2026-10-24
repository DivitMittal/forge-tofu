variable "project_ids" {
  description = "Map of repository name to GitLab project ID. Provided by the repositories-gitlab module output."
  type        = map(string)
}

variable "protected_branches" {
  description = "Map of repo name to branch protection config. Defined per org in generated locals and passed in from the root module."
  type        = map(object({ branch = string }))
}
