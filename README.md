<h1 align='center'>forge-tofu</h1>
<div align='center'>
    <p></p>
    <div align='center'>
        <a href='https://github.com/DivitMittal/forge-tofu'>
            <img src='https://img.shields.io/github/repo-size/DivitMittal/forge-tofu?&style=for-the-badge&logo=github'>
        </a>
        <a href='https://github.com/DivitMittal/forge-tofu/blob/main/LICENSE'>
            <img src='https://img.shields.io/static/v1.svg?style=for-the-badge&label=License&message=MIT&logo=unlicense'/>
        </a>
        <a href='https://github.com/DivitMittal/forge-tofu'>
            <img src='https://img.shields.io/badge/OpenTofu-%3E%3D1.10-FFDA18?style=for-the-badge&logo=opentofu'/>
        </a>
        <a href='https://registry.terraform.io/providers/integrations/github/latest'>
            <img src='https://img.shields.io/badge/GitHub_Provider-~%3E6.0-181717?style=for-the-badge&logo=github'/>
        </a>
    </div>
    <br>
</div>

---

<div align='center'>
    <a href="https://github.com/DivitMittal/forge-tofu/actions/workflows/flake-check.yml">
        <img src="https://github.com/DivitMittal/forge-tofu/actions/workflows/flake-check.yml/badge.svg" alt="nix-flake-check"/>
    </a>
    <a href="https://github.com/DivitMittal/forge-tofu/actions/workflows/flake-lock-update.yml">
        <img src="https://github.com/DivitMittal/forge-tofu/actions/workflows/flake-lock-update.yml/badge.svg" alt="Update flake.lock"/>
    </a>
</div>

---

OpenTofu + Terragrunt project that declaratively manages repositories and branch protections across multiple forges — GitHub, GitLab, Codeberg, gitea.com, and SourceHut — for the `DivitMittal` and `Qezta` accounts/organisations. `terranix/orgs/<Org>[-<Forge>].nix` files are the source of truth for repository definitions, compiled to Terraform/OpenTofu JSON by [Terranix](https://terranix.org/). A [Nix flake](https://github.com/DivitMittal/forge-tofu/blob/main/flake.nix) provides the devshell, formatters, pre-commit hooks, Terranix JSON generation, and CI workflow generation.

## Architecture

```
forge-tofu/
├── root.hcl                          # shared Terragrunt backend/version generation (GitHub, default)
├── orgs/                             # per-org Terragrunt units
│   ├── DivitMittal/                  # GitHub — github.com/DivitMittal
│   ├── Qezta/                        # GitHub — github.com/Qezta
│   ├── DivitMittal-GitLab/           # GitLab — overrides generate blocks for gitlabhq/gitlab
│   ├── Qezta-GitLab/
│   ├── DivitMittal-Codeberg/         # Codeberg — overrides generate blocks for go-gitea/gitea
│   ├── Qezta-Codeberg/
│   ├── DivitMittal-Gitea/            # gitea.com — same Gitea provider, different base_url
│   ├── DivitMittal-Sourcehut/        # SourceHut — overrides generate blocks for wombelix/sourcehut
│   └── Qezta-Sourcehut/
├── terranix/orgs/                    # canonical org repo maps — edit here, not the generated JSON
├── modules/
│   ├── repositories/                 # github_repository resources + validation
│   ├── branch-protection/            # github_branch_protection
│   ├── actions-environments/         # github_repository_environment + secrets/variables
│   ├── repositories-gitlab/          # gitlab_project resources + validation
│   ├── branch-protection-gitlab/     # gitlab_branch_protection
│   ├── repositories-gitea/           # gitea_repository resources (Codeberg, gitea.com, or any Gitea instance)
│   ├── branch-protection-gitea/      # gitea_repository_branch_protection
│   └── repositories-sourcehut/       # sourcehut_repository resources (no branch-protection support)
└── flake/                            # devshell, formatters, pre-commit, Terranix, CI generation
    └── actions/                      # source for .github/workflows/*.yml
```

### Key Patterns

- **Single source of truth**: all repo definitions live in `terranix/orgs/<Org>[-<Forge>].nix`; Terragrunt generates `locals.tf.json` for OpenTofu.
- **Fork policy**: fork repositories are intentionally unmanaged; omit forks from Terranix repo maps.
- **Module wiring**: `repositories` outputs `node_ids`; `branch_protection` receives them via `var.repo_node_ids` — avoids cross-module resource references.
- **Import blocks**: pre-existing repos are adopted in-place, never recreated.
- **`prevent_destroy = true`**: every repository resource, on every forge, is guarded against accidental deletion.
- **`check` block**: validates all active repos have descriptions before any apply.
- **Generated CI**: workflows in `.github/workflows/` are rendered from `flake/actions/` — do not edit by hand.

## Usage

### Prerequisites

- [Nix](https://nixos.org/) with flakes enabled
- API tokens for whichever forges you're managing (`GITHUB_TOKEN`, `GITLAB_TOKEN_<ORG>`, `CODEBERG_TOKEN_<ORG>`, `GITEA_TOKEN_DIVITMITTAL`, `SOURCEHUT_TOKEN_<ORG>` — see `.claude/rules/project-knowledge.md` for the full token/fallback matrix)

### Development Environment

Enter the Nix devshell (provides `tofu`, `terragrunt`, `gh`, `nixd`, `alejandra`):

```bash
nix develop
# or automatically via direnv:
direnv allow
```

### Common Commands

```bash
# Plan changes inside one org unit
cd orgs/DivitMittal # or any other orgs/<Org>[-<Forge>] directory
terragrunt plan

# Apply changes
terragrunt apply

# Plan/apply every org unit at once
terragrunt run --all plan

# Format all Nix and Terraform/OpenTofu files
nix fmt

# Run pre-commit checks (formatters, secret detection, etc.)
nix flake check

# Regenerate .github/workflows/ from flake/actions/
nix run .#render-workflows
```

### Adding a New Repository

1. Add an entry to `locals.repos` in the relevant `terranix/orgs/<Org>[-<Forge>].nix`:

```nix
"my-new-repo" = {
  description = "What this repo is for";
  visibility = "public";
  topics = ["nix" "example"]; # GitHub/GitLab only
  delete_branch_on_merge = true; # GitHub/GitLab only
  existing = false; # omit or set true for pre-existing repos
};
```

2. If adopting a **pre-existing** repo, rely on the `for_each` import block in that org's `main.tf` (repos with `existing = true` are imported automatically).

3. If branch protection is needed, add the repo + branch to `locals.protected_branches` in the same Terranix file (not supported on SourceHut).

4. Verify and apply:

```bash
terragrunt plan
terragrunt apply
```

## CI/CD

GitHub Actions workflows are **generated from Nix** (`flake/actions/`):

| Workflow            | Trigger                                      | Purpose                                                            |
| ------------------- | --------------------------------------------- | ------------------------------------------------------------------ |
| `flake-check`       | push/PR touching `flake.nix` or `flake.lock` | Runs `nix flake check`                                             |
| `flake-lock-update` | weekly schedule                              | Auto-updates Nix inputs via `DeterminateSystems/update-flake-lock` |
