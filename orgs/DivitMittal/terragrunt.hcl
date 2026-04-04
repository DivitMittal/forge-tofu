include "root" {
  path = find_in_parent_folders("root.hcl")
}

# Generate provider with DivitMittal as owner.
# Token is injected via inputs below — set GITHUB_TOKEN_DIVITMITTAL in env,
# or fall back to GITHUB_TOKEN.
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF
    provider "github" {
      owner = "DivitMittal"
      token = var.github_token
    }
  EOF
}

inputs = {
  github_token = get_env("GITHUB_TOKEN_DIVITMITTAL", get_env("GITHUB_TOKEN", ""))
}
