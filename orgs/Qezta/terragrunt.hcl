include "root" {
  path = find_in_parent_folders("root.hcl")
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
