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

# Override the root's `versions` generate block: this unit talks to GitLab,
# not GitHub, so it needs the gitlabhq/gitlab provider instead.
generate "versions" {
  path      = "versions.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF
    terraform {
      required_version = ">= 1.7" # for_each import blocks

      required_providers {
        gitlab = {
          source  = "gitlabhq/gitlab"
          version = "~> 19.0"
        }
      }
    }
  EOF
}

# Token is injected via inputs below — set GITLAB_TOKEN_DIVITMITTAL in env,
# fall back to GITLAB_TOKEN. No CLI-auth fallback (unlike `gh auth token`
# for GitHub) since this repo doesn't assume a `glab` login.
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF
    provider "gitlab" {
      token = var.gitlab_token
    }
  EOF
}

# Materialise `locals.tf.json` from the terranix module at
# `terranix/orgs/DivitMittal-GitLab.nix`. Edit the .nix file, not generated JSON.
generate "locals" {
  path              = "locals.tf.json"
  if_exists         = "overwrite"
  disable_signature = true
  contents = run_cmd(
    "--terragrunt-quiet",
    "--terragrunt-global-cache",
    "sh", "-c",
    "nix build --no-link --print-out-paths '${get_repo_root()}#divitmittal-gitlab-locals' | xargs cat",
  )
}

inputs = {
  gitlab_token = get_env("GITLAB_TOKEN_DIVITMITTAL", get_env("GITLAB_TOKEN", ""))

  # GitLab group namespace ID that owns these projects, once any exist.
  # Leave null to create projects under the authenticated user's personal
  # namespace instead of a group.
  gitlab_namespace_id = null
}
