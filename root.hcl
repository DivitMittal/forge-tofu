# ---------------------------------------------------------------------------
# Root Terragrunt configuration — inherited by all org units via
# find_in_parent_folders(). Centralises the backend type and the terraform{}
# version block so individual orgs stay DRY.
# ---------------------------------------------------------------------------

# ---------------------------------------------------------------------------
# Backend: local state stored adjacent to each org's terragrunt.hcl.
# path_relative_to_include() yields e.g. "orgs/DivitMittal" from the child.
# To switch to GCS, change backend = "gcs" and update config below.
# ---------------------------------------------------------------------------
remote_state {
  backend = "local"
  config = {
    path = "${get_repo_root()}/${path_relative_to_include()}/terraform.tfstate"
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

# ---------------------------------------------------------------------------
# Generate terraform{} so no org unit repeats provider version constraints.
# ---------------------------------------------------------------------------
generate "versions" {
  path      = "versions.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF
    terraform {
      required_version = ">= 1.7" # for_each import blocks

      required_providers {
        github = {
          source  = "integrations/github"
          version = "~> 6.0"
        }
      }
    }
  EOF
}
