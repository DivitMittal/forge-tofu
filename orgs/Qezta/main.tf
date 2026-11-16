# ---------------------------------------------------------------------------
# Qezta GitHub management has moved to github.com/Qezta/infra (2026-11).
#
# This unit exists only to make OpenTofu *forget* the resources it used to
# manage, without destroying anything on GitHub. Run `terragrunt plan` and
# confirm every resource says "will no longer be managed", then apply once.
# After that apply this whole unit can be deleted.
# ---------------------------------------------------------------------------
removed {
  from = module.repositories.github_repository.repos

  lifecycle {
    destroy = false
  }
}

removed {
  from = module.repositories.github_workflow_repository_permissions.repos

  lifecycle {
    destroy = false
  }
}
