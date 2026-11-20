# ---------------------------------------------------------------------------
# Root Terragrunt configuration — inherited by all org units via
# find_in_parent_folders(). Centralises the backend and the terraform{}
# version block so individual orgs stay DRY.
# ---------------------------------------------------------------------------

# ---------------------------------------------------------------------------
# Backend: local state file per org unit.
# State is stored at <org-dir>/terraform.tfstate on disk.
# ---------------------------------------------------------------------------
remote_state {
  backend = "local"
  config = {
    path = "${get_parent_terragrunt_dir()}/${path_relative_to_include()}/terraform.tfstate"
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

# ---------------------------------------------------------------------------
# Generate terraform{} so no org unit repeats provider version constraints.
# OpenTofu >= 1.10 is the GitHub unit's floor (for_each import blocks need
# >= 1.7, plus its state encryption). Non-GitHub units override this block.
# ---------------------------------------------------------------------------
generate "versions" {
  path      = "versions.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF
    terraform {
      required_version = ">= 1.10" # see comment above

      required_providers {
        github = {
          source  = "integrations/github"
          version = "~> 6.0"
        }
      }
    }
  EOF
}
