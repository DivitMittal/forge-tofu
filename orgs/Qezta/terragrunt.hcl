include "root" {
  path = find_in_parent_folders("root.hcl")
}

# Qezta GitHub management has moved to Qezta/infra; see main.tf. Only the
# provider is still needed so OpenTofu can plan the `removed` blocks.
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF2
    provider "github" {
      owner = "Qezta"
      token = var.github_token
    }
  EOF2
}

inputs = {
  github_token = get_env("GITHUB_TOKEN_QEZTA", get_env("GITHUB_TOKEN", run_cmd("--terragrunt-quiet", "gh", "auth", "token")))
}
