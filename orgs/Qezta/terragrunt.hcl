include "root" {
  path = find_in_parent_folders("root.hcl")
}

# Copy the repo root into the Terragrunt cache and run Terraform from this
# org's subdirectory within it, so that relative module paths (../../modules)
# resolve correctly.
terraform {
  source = "${get_repo_root()}//${path_relative_to_include()}"
}

# Generate provider with Qezta as owner.
# Token is injected via inputs below — set GITHUB_TOKEN_QEZTA in env,
# or fall back to GITHUB_TOKEN.
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF
    provider "github" {
      owner = "Qezta"
      token = var.github_token
    }
  EOF
}

inputs = {
  github_token = get_env("GITHUB_TOKEN_QEZTA", get_env("GITHUB_TOKEN", ""))
}
