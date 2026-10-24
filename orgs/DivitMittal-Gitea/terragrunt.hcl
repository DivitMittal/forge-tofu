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

# Override the root's `versions` generate block: this unit talks to gitea.com
# (Gitea's own hosted instance, distinct from Codeberg), so it needs the
# go-gitea/gitea provider instead.
generate "versions" {
  path      = "versions.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF
    terraform {
      required_version = ">= 1.7" # for_each import blocks

      required_providers {
        gitea = {
          source  = "go-gitea/gitea"
          version = "~> 0.8"
        }
      }
    }
  EOF
}

# Token is injected via inputs below — set GITEA_TOKEN_DIVITMITTAL in env,
# fall back to GITEA_TOKEN. No CLI-auth fallback (unlike `gh auth token`
# for GitHub) since Gitea has no equivalent official CLI.
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF
    provider "gitea" {
      base_url = "https://gitea.com"
      token    = var.gitea_token
    }
  EOF
}

# Materialise `locals.tf.json` from the terranix module at
# `terranix/orgs/DivitMittal-Gitea.nix`. Edit the .nix file, not generated JSON.
generate "locals" {
  path              = "locals.tf.json"
  if_exists         = "overwrite"
  disable_signature = true
  contents = run_cmd(
    "--terragrunt-quiet",
    "--terragrunt-global-cache",
    "sh", "-c",
    "nix build --no-link --print-out-paths '${get_repo_root()}#divitmittal-gitea-locals' | xargs cat",
  )
}

inputs = {
  gitea_token = get_env("GITEA_TOKEN_DIVITMITTAL", get_env("GITEA_TOKEN", ""))
  gitea_owner = "DivitMittal"
}
