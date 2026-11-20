include "root" {
  path = find_in_parent_folders("root.hcl")
}

# Copy the repo root into the Terragrunt cache and run OpenTofu from this
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

locals {
  state_migration = get_env("FORGE_TOFU_ALLOW_PLAINTEXT_STATE_MIGRATION", "false") == "true"
  actions_secret_sources = {
    profile_readme_token   = "forge/github/profile_readme.age"
    awesome_github_token   = "forge/github/awesome_stars.age"
    awesome_codeberg_token = "forge/codeberg.age"
    awesome_gitea_token    = "forge/gitea.age"
    awesome_gitlab_token   = "forge/gitlab.age"

    # infra-nixCfg `dev` environment. ATTIC_TOKEN is the T2/T3 push token.
    infra_nixcfg_attic_token = "homelab/attic-push.age"
    # Enable each source only when its age file exists, together with moving
    # its declaration from pending_secrets to secrets in the Terranix map.
    # infra_nixcfg_cachix_auth_token  = "ci/infra-nixCfg/cachix_auth_token.age"
    # infra_nixcfg_pat                = "ci/infra-nixCfg/pat.age"
    # infra_nixcfg_ssh_private_key    = "ci/infra-nixCfg/ssh_private_key.age"
    # Tailscale provider outputs are encrypted directly to these two paths by
    # infra-nixCfg's `nix run .#tailscale-personal -- export-secrets` command.
    infra_nixcfg_ts_oauth_client_id = "ci/infra-nixCfg/ts_oauth_client_id.age"
    infra_nixcfg_ts_oauth_secret    = "ci/infra-nixCfg/ts_oauth_secret.age"
    # infra_nixcfg_attic_darwin_token = "ci/infra-nixCfg/attic_darwin_token.age"
  }
}

generate "encryption" {
  path      = "encryption.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF
    terraform {
      encryption {
        key_provider "pbkdf2" "state" {
          passphrase = var.tofu_state_passphrase
        }
        method "aes_gcm" "state" {
          keys = key_provider.pbkdf2.state
        }
        method "unencrypted" "migration" {}
        state {
          method = method.aes_gcm.state
          enforced = ${!local.state_migration}
          ${local.state_migration ? "fallback { method = method.unencrypted.migration }" : ""}
        }
        plan {
          method = method.aes_gcm.state
          enforced = true
        }
      }
    }
  EOF
}

inputs = {
  tofu_state_passphrase = run_cmd("--terragrunt-quiet", "${get_repo_root()}/scripts/read-actions-secret", "tofu_state_passphrase", "forge/tofu/github-state-passphrase.age")
  github_token          = get_env("GITHUB_TOKEN_DIVITMITTAL", get_env("GITHUB_TOKEN", run_cmd("--terragrunt-quiet", "gh", "auth", "token")))

  github_actions_secret_values = {
    for name, path in local.actions_secret_sources :
    name => run_cmd("--terragrunt-quiet", "${get_repo_root()}/scripts/read-actions-secret", name, path)
  }
}
