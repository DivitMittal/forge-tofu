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

OpenTofu + Terragrunt project that declaratively manages the `DivitMittal` repositories and branch protections across multiple forges: GitHub, GitLab, Codeberg, gitea.com and SourceHut (Qezta moved to [Qezta/infra](https://github.com/Qezta/infra)). `terranix/orgs/<Org>[-<Forge>].nix` files are the source of truth for repository definitions, compiled to OpenTofu JSON by [Terranix](https://terranix.org/). A [Nix flake](https://github.com/DivitMittal/forge-tofu/blob/main/flake.nix) provides the devshell, formatters, pre-commit hooks, Terranix JSON generation, and CI workflow generation.

## Architecture

```
forge-tofu/
├── root.hcl                          # shared Terragrunt backend/version generation (GitHub, default)
├── orgs/                             # per-org Terragrunt units
│   ├── DivitMittal/                  # GitHub: github.com/DivitMittal
│   ├── DivitMittal-GitLab/           # GitLab: overrides generate blocks for gitlabhq/gitlab
│   ├── DivitMittal-Codeberg/         # Codeberg: overrides generate blocks for go-gitea/gitea
│   ├── DivitMittal-Gitea/            # gitea.com: same Gitea provider, different base_url
│   └── DivitMittal-Sourcehut/        # SourceHut: overrides generate blocks for wombelix/sourcehut
├── terranix/orgs/                    # canonical org repo maps: edit here, not the generated JSON
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
- A checkout of `infra-nixCfg-secrets` at `../../Cfgs/infra-nixCfg-secrets` relative to this repo, and its agenix key at `~/.ssh/agenix/id_ed25519` (override with `FORGE_TOFU_SECRETS_REPO` / `FORGE_TOFU_AGE_IDENTITY`). The GitLab, Codeberg, gitea.com and SourceHut tokens are decrypted from `secrets/forge/tofu/*.age`; set `GITLAB_TOKEN_DIVITMITTAL`, `CODEBERG_TOKEN_DIVITMITTAL`, `GITEA_TOKEN_DIVITMITTAL` or `SOURCEHUT_TOKEN_DIVITMITTAL` to use a different token
- A GitHub token (`GITHUB_TOKEN_DIVITMITTAL`, `GITHUB_TOKEN`, or a `gh auth login` session)

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
cd orgs/DivitMittal # or any other orgs/DivitMittal-<Forge> directory
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

### Managing GitHub Actions Environments

`locals.actions_environments` in `terranix/orgs/DivitMittal.nix` maps `repo -> environment -> config`. Each secret maps a GitHub secret name to a logical source key; `orgs/DivitMittal/terragrunt.hcl` maps that key to an age file under `infra-nixCfg-secrets/secrets/`, which `scripts/read-actions-secret` decrypts at plan/apply time:

```nix
"infra-nixCfg".dev = {
  existing = true;                                   # import the live environment instead of creating it
  secrets.CACHIX_AUTH_TOKEN = "infra_nixcfg_cachix_auth_token";
  pending_secrets.ATTIC_DARWIN_TOKEN = "infra_nixcfg_attic_darwin_token";
  variables = {};                                    # plaintext, public values only
  pending_variables = ["DARWIN_CACHE_PUBLIC_KEY"];
  existing_variables = ["CACHE_ARTIFACT_RECIPIENT"]; # imported once declared in `variables`
};
```

```hcl
# orgs/DivitMittal/terragrunt.hcl -> locals.actions_secret_sources
infra_nixcfg_cachix_auth_token = "ci/infra-nixCfg/cachix_auth_token.age"
```

- **Adopting**: `existing = true` (the default) adds the environment to an import block, so the first `terragrunt apply` imports it rather than recreating it. Use `existing = false` only for environments forge-tofu should create.
- **Secrets are write-only**: GitHub never returns a secret's value, so the first apply PUTs every declared secret from its age file and overwrites the live value. Encrypt the current value (or a freshly rotated one) before applying.
- **Missing age files fail closed**: `read-actions-secret` exits non-zero when a source's age file is missing, which aborts the whole plan. `FORGE_TOFU_PLACEHOLDER_SECRETS=1` substitutes `PLACEHOLDER__MISSING_SECRET__*` values for offline rendering, but a precondition refuses to plan any secret resource with a placeholder, so a placeholder can never reach GitHub.
- **Pending entries**: declare secrets or variables that do not have an age file or value yet under `pending_secrets` / `pending_variables`. They are only reported (`tofu output actions_environments_pending`), never created or deleted. To activate one, encrypt its age file, move it into `secrets` (or `variables` with its value), and add its path to `actions_secret_sources`.
- **Existing variables**: the provider creates variables with a POST, which fails on a name that already exists. List such names in `existing_variables`; they are imported once they also appear in `variables`.
- **Unmanaged names**: secrets and variables that are not declared are left alone. forge-tofu does not delete what it never managed.

## CI/CD

GitHub Actions workflows are **generated from Nix** (`flake/actions/`):

| Workflow            | Trigger                                      | Purpose                                                            |
| ------------------- | --------------------------------------------- | ------------------------------------------------------------------ |
| `flake-check`       | push/PR touching `flake.nix` or `flake.lock` | Runs `nix flake check`                                             |
| `flake-lock-update` | weekly schedule                              | Auto-updates Nix inputs via `DeterminateSystems/update-flake-lock` |

### Personal Tailscale CI identity

`DivitMittal/infra-nixCfg` owns the personal tailnet policy and the CI OAuth
client through its Tailscale provider. This repository owns delivering that
client's credentials to GitHub; it does not read the networking state.

After applying the tailnet configuration, its `tailscale-personal export-secrets`
command writes `ci/infra-nixCfg/ts_oauth_client_id.age` and
`ci/infra-nixCfg/ts_oauth_secret.age` directly into the private secrets checkout.
Register their recipients in the secrets manifest and commit the encrypted
files. Then move `TS_OAUTH_CLIENT_ID` and `TS_OAUTH_SECRET` from
`pending_secrets` to `secrets`, uncomment their two `actions_secret_sources`,
and review a forge plan before applying. No tailnet administrator credential
is sent to GitHub, and no shared Terraform state is needed.

Other existing environment secrets remain pending until their encrypted
sources are available. Pending entries leave existing GitHub values intact
and do not block unrelated repository plans.

### Encrypted GitHub state and Tailscale delivery

The DivitMittal GitHub unit now receives the dedicated Tailscale CI OAuth
pair from `ci/infra-nixCfg/ts_oauth_{client_id,secret}.age`. Other unavailable
sources remain pending. The client is created by infra-nixCfg's provider;
this unit only delivers its credentials to the existing `dev` environment.

State and saved plans for this unit use enforced PBKDF2/AES-GCM encryption.
The passphrase is decrypted at runtime from
`forge/tofu/github-state-passphrase.age`, separately from GitHub secrets.
Retain that encrypted input for state recovery. Existing plaintext state
must be backed up to age encryption before migration. For that one-time
migration only, `FORGE_TOFU_ALLOW_PLAINTEXT_STATE_MIGRATION=true` permits
reading old plaintext state while all writes and saved plans use encryption.
Remove the flag after migration; the default rejects plaintext state.
This setting does not change the other forge units.
