locals {
  # Repos map is passed in from the root module so that import blocks
  # (which Terraform only allows in the root) can reference the same data.
  repos = var.repos
}
