# ---------------------------------------------------------------------------
# Root Terragrunt configuration — inherited by all org units via
# find_in_parent_folders(). Centralises the backend and the terraform{}
# version block so individual orgs stay DRY.
# ---------------------------------------------------------------------------

# ---------------------------------------------------------------------------
# Backend: S3-compatible object store (Cloudflare R2 by default).
#
# Required env vars at terragrunt invocation time:
#   AWS_ACCESS_KEY_ID       R2 access key (or AWS access key)
#   AWS_SECRET_ACCESS_KEY   R2 secret key (or AWS secret key)
#   TF_BACKEND_BUCKET       state bucket name
#   TF_BACKEND_ENDPOINT     R2 S3 endpoint, e.g.
#                           https://<account>.r2.cloudflarestorage.com
#                           Leave empty to use AWS S3.
#
# Locking uses Terraform's native S3 lockfile (`use_lockfile = true`,
# Terraform >= 1.10). R2 supports the conditional-write semantics required —
# no DynamoDB needed. For AWS S3, the same flag uses S3 conditional writes.
# ---------------------------------------------------------------------------
remote_state {
  backend = "s3"
  config = {
    bucket = get_env("TF_BACKEND_BUCKET", "")
    key    = "${path_relative_to_include()}/terraform.tfstate"
    region = "auto" # R2 ignores; AWS overrides via AWS_REGION env var

    endpoints = {
      s3 = get_env("TF_BACKEND_ENDPOINT", "")
    }

    use_lockfile = true

    # R2 quirks — harmless on AWS S3 when endpoint is unset
    skip_credentials_validation = true
    skip_region_validation      = true
    skip_metadata_api_check     = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

# ---------------------------------------------------------------------------
# Generate terraform{} so no org unit repeats provider version constraints.
# Terraform >= 1.10 is required for `use_lockfile = true` on the S3 backend.
# ---------------------------------------------------------------------------
generate "versions" {
  path      = "versions.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF
    terraform {
      required_version = ">= 1.10" # for_each import blocks + use_lockfile

      required_providers {
        github = {
          source  = "integrations/github"
          version = "~> 6.0"
        }
      }
    }
  EOF
}
