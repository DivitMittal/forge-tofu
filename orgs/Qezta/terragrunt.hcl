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
# fall back to GITHUB_TOKEN, then to the logged-in gh CLI token.
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

# Materialise `locals.tf.json` from the terranix module at
# `terranix/orgs/Qezta.nix`. Edit the .nix file, not generated JSON.
generate "locals" {
  path              = "locals.tf.json"
  if_exists         = "overwrite"
  disable_signature = true
  contents = run_cmd(
    "--terragrunt-quiet",
    "--terragrunt-global-cache",
    "sh", "-c",
    "nix build --no-link --print-out-paths '${get_repo_root()}#qezta-locals' | xargs cat",
  )
}

locals {
  actions_secret_sources = {
    github                                = "github/general.age"
    gemini                                = "api/gemini.age"
    groq                                  = "api/groq.age"
    hf                                    = "api/hf.age"
    openrouter                            = "api/openrouter.age"
    opencode                              = "api/opencode.age"
    discord                               = "api/discord.age"
    google_client_id                      = "google/client_id.age"
    google_client_secret                  = "google/client_secret.age"
    vercel_token                          = "api/vercel.age"
    vercel_org_id                         = "vercel/org_id.age"
    vercel_project_id_qezta_website_divit = "vercel/project_id_qezta_website_divit.age"
    vercel_project_id_qezta_website_qezta = "vercel/project_id_qezta_website_qezta.age"
  }
}

inputs = {
  github_token = get_env("GITHUB_TOKEN_QEZTA", get_env("GITHUB_TOKEN", run_cmd("--terragrunt-quiet", "gh", "auth", "token")))

  github_actions_secret_values = {
    for name, path in local.actions_secret_sources :
    name => run_cmd("--terragrunt-quiet", "${get_repo_root()}/scripts/read-actions-secret", name, path)
  }
}
