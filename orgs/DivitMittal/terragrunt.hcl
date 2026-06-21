include "root" {
  path = find_in_parent_folders("root.hcl")
}

# Copy the repo root into the Terragrunt cache and run Terraform from this
# org's subdirectory within it, so that relative module paths (../../modules)
# resolve correctly.
terraform {
  source = "${get_repo_root()}//${path_relative_to_include()}"
}

# Generate provider with DivitMittal as owner.
# Token is injected via inputs below — set GITHUB_TOKEN_DIVITMITTAL in env,
# fall back to GITHUB_TOKEN, then to the logged-in gh CLI token.
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

# Materialise `locals.tf.json` from the terranix module at
# `terranix/orgs/DivitMittal.nix`. The nix store output is built once per
# terragrunt invocation (`--terragrunt-global-cache`) and inlined here.
# Edit the .nix file, not this file or any `locals.tf.json` on disk.
generate "locals" {
  path              = "locals.tf.json"
  if_exists         = "overwrite"
  disable_signature = true
  contents = run_cmd(
    "--terragrunt-quiet",
    "--terragrunt-global-cache",
    "sh", "-c",
    "nix build --no-link --print-out-paths '${get_repo_root()}#divitmittal-locals' | xargs cat",
  )
}

inputs = {
  github_token = get_env("GITHUB_TOKEN_DIVITMITTAL", get_env("GITHUB_TOKEN", run_cmd("--terragrunt-quiet", "gh", "auth", "token")))
}
