include "root" {
  path           = find_in_parent_folders("root.hcl")
  merge_strategy = "deep"
}

# Copy the repo root into the Terragrunt cache and run Terraform from this
# org's subdirectory within it, so that relative module paths (../../modules)
# resolve correctly.
terraform {
  source = "${get_repo_root()}//${path_relative_to_include()}"
}

# Override the root's `versions` generate block: this unit talks to
# SourceHut, not GitHub, so it needs the wombelix/sourcehut provider instead.
# That provider's GraphQL backend requires Terraform >= 1.8.
generate "versions" {
  path      = "versions.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF
    terraform {
      required_version = ">= 1.8"

      required_providers {
        sourcehut = {
          source  = "wombelix/sourcehut"
          version = "~> 1.0"
        }
      }
    }
  EOF
}

# Token is injected via inputs below — set SOURCEHUT_TOKEN_DIVITMITTAL in
# env, fall back to SRHT_TOKEN (the provider's own conventional env var).
# No CLI-auth fallback (unlike `gh auth token` for GitHub).
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF
    provider "sourcehut" {
      token = var.sourcehut_token
    }
  EOF
}

# Materialise `locals.tf.json` from the terranix module at
# `terranix/orgs/DivitMittal-Sourcehut.nix`. Edit the .nix file, not generated JSON.
generate "locals" {
  path              = "locals.tf.json"
  if_exists         = "overwrite"
  disable_signature = true
  contents = run_cmd(
    "--terragrunt-quiet",
    "--terragrunt-global-cache",
    "sh", "-c",
    "nix build --no-link --print-out-paths '${get_repo_root()}#divitmittal-sourcehut-locals' | xargs cat",
  )
}

inputs = {
  sourcehut_token = get_env("SOURCEHUT_TOKEN_DIVITMITTAL", get_env("SRHT_TOKEN", ""))
  sourcehut_owner = "DivitMittal"
}
