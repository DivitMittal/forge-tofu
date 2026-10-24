locals {
  # Repos where we enforce branch protection rules.
  # Supplied per org via var.protected_branches from generated org locals.
  protected_branches = var.protected_branches
}
