<h1 align='center'>ghOrg-terraform</h1>
<div align='center'>
    <p></p>
    <div align='center'>
        <a href='https://github.com/DivitMittal/ghOrg-terraform'>
            <img src='https://img.shields.io/github/repo-size/DivitMittal/ghOrg-terraform?&style=for-the-badge&logo=github'>
        </a>
        <a href='https://github.com/DivitMittal/ghOrg-terraform/blob/main/LICENSE'>
            <img src='https://img.shields.io/static/v1.svg?style=for-the-badge&label=License&message=MIT&logo=unlicense'/>
        </a>
        <a href='https://github.com/DivitMittal/ghOrg-terraform'>
            <img src='https://img.shields.io/badge/Terraform-%3E%3D1.7-623CE4?style=for-the-badge&logo=terraform'/>
        </a>
        <a href='https://registry.terraform.io/providers/integrations/github/latest'>
            <img src='https://img.shields.io/badge/GitHub_Provider-~%3E6.0-181717?style=for-the-badge&logo=github'/>
        </a>
    </div>
    <br>
</div>

---

<div align='center'>
    <a href="https://github.com/DivitMittal/ghOrg-terraform/actions/workflows/flake-check.yml">
        <img src="https://github.com/DivitMittal/ghOrg-terraform/actions/workflows/flake-check.yml/badge.svg" alt="nix-flake-check"/>
    </a>
    <a href="https://github.com/DivitMittal/ghOrg-terraform/actions/workflows/flake-lock-update.yml">
        <img src="https://github.com/DivitMittal/ghOrg-terraform/actions/workflows/flake-lock-update.yml/badge.svg" alt="Update flake.lock"/>
    </a>
</div>

---

Terraform + Terragrunt project that declaratively manages the `DivitMittal` and `Qezta` GitHub organisations' repositories and branch protections via the [GitHub provider](https://registry.terraform.io/providers/integrations/github/latest). `terranix/orgs/<Org>.nix` files are the source of truth for repository definitions. A [Nix flake](https://github.com/DivitMittal/ghOrg-terraform/blob/main/flake.nix) provides the devshell, formatters, pre-commit hooks, Terranix JSON generation, and CI workflow generation.

## Architecture

```
ghOrg-terraform/
├── root.hcl                  # shared Terragrunt backend/version generation
├── orgs/                     # per-org Terragrunt units
├── terranix/orgs/            # canonical org repo maps — edit here
├── modules/
│   ├── repositories/
│   │   ├── locals.tf         # repo map (passed from root)
│   │   ├── main.tf           # github_repository resource + check block
│   │   └── outputs.tf        # node_ids, repo_urls, counts
│   └── branch-protection/
│       ├── locals.tf         # protected_branches map
│       ├── variables.tf      # repo_node_ids input
│       ├── main.tf           # github_branch_protection resource
│       └── outputs.tf        # protected_branch_rules
└── flake/                    # Nix: devshell, formatters, pre-commit, Terranix, CI generation
    └── actions/              # source for .github/workflows/*.yml
```

### Key Patterns

- **Single source of truth**: all repo definitions live in `terranix/orgs/<Org>.nix`; Terragrunt generates `locals.tf.json` for Terraform.
- **Fork policy**: fork repositories are intentionally unmanaged; omit forks from Terranix repo maps.
- **Module wiring**: `repositories` outputs `node_ids`; `branch_protection` receives them via `var.repo_node_ids` — avoids cross-module resource references.
- **Import blocks** (Terraform ≥ 1.7): pre-existing repos are adopted in-place, never recreated.
- **`prevent_destroy = true`**: every repository resource is guarded against accidental deletion.
- **`check` block**: validates all active repos have descriptions before any apply.
- **`moved` blocks**: migrate state from old flat root addresses to module addresses — safe to remove after first apply.
- **Generated CI**: workflows in `.github/workflows/` are rendered from `flake/actions/` — do not edit by hand.

## Usage

### Prerequisites

- [Nix](https://nixos.org/) with flakes enabled
- `GITHUB_TOKEN` environment variable set with appropriate org permissions

### Development Environment

Enter the Nix devshell (provides `terraform`, `gh`, `nixd`, `alejandra`):

```bash
nix develop
# or automatically via direnv:
direnv allow
```

### Common Commands

```bash
# Plan changes inside one org
cd orgs/DivitMittal # or orgs/Qezta
terragrunt plan

# Apply changes
terragrunt apply

# Format all Nix and Terraform files
nix fmt

# Run pre-commit checks (formatters, secret detection, etc.)
nix flake check

# Regenerate .github/workflows/ from flake/actions/
nix run .#render-workflows
```

### Adding a New Repository

1. Add an entry to `locals.repos` in `terranix/orgs/<Org>.nix`:

```nix
"my-new-repo" = {
  description = "What this repo is for";
  visibility = "public";
  topics = ["nix" "example"];
  delete_branch_on_merge = true;
  existing = false; # omit or set true for pre-existing repos
};
```

2. If adopting a **pre-existing** repo, add a corresponding `import` block in `main.tf` (or rely on the `for_each` import block for repos where `existing = true`).

3. If branch protection is needed, add the repo + branch to `locals.protected_branches` in the same org Terranix file.

4. Verify and apply:

```bash
terragrunt plan
terragrunt apply
```

## CI/CD

GitHub Actions workflows are **generated from Nix** (`flake/actions/`):

| Workflow            | Trigger                                      | Purpose                                                            |
| ------------------- | -------------------------------------------- | ------------------------------------------------------------------ |
| `flake-check`       | push/PR touching `flake.nix` or `flake.lock` | Runs `nix flake check`                                             |
| `flake-lock-update` | weekly schedule                              | Auto-updates Nix inputs via `DeterminateSystems/update-flake-lock` |
