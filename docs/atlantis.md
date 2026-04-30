# Atlantis bring-up

PR-driven `terragrunt plan`/`apply` for both orgs (`DivitMittal`, `Qezta`), running on a self-hosted Atlantis instance.

## Status

- **Phase 1 — repo-side prep:** done (this changeset).
- **Phase 2 — k3d cluster + Atlantis manifests:** not yet started.
- **Phase 3 — webhook wire-up + first PR test:** not yet started.

## Phase 1 — what changed

| File                                 | Purpose                                                                                                  |
| ------------------------------------ | -------------------------------------------------------------------------------------------------------- |
| `root.hcl`                           | Backend switched from `local` → `s3` (Cloudflare R2 by default). `required_version` bumped to `>= 1.10`. |
| `atlantis.yaml`                      | Repo-side Atlantis config: two projects + custom `terragrunt-nix` workflow.                              |
| `docker/atlantis/Dockerfile`         | Custom Atlantis image with `terragrunt` + `nix-portable`.                                                |
| `flake/actions/atlantis-image.nix`   | Generates `.github/workflows/atlantis-image.yml` to build & push the image to GHCR multi-arch.           |

## One-time bring-up

### 1. Cloudflare R2 setup

**Bucket (already created):** `ghorg-terraform-state`
**Account ID:** `b22e4e9b05781ff42d6e61da16c57bdb`
**S3 endpoint:** `https://b22e4e9b05781ff42d6e61da16c57bdb.r2.cloudflarestorage.com`
**Region:** `APAC` (auto-selected; irrelevant for S3-API access)

The bucket was provisioned via wrangler:

```sh
wrangler r2 bucket create ghorg-terraform-state
wrangler r2 bucket info   ghorg-terraform-state   # to verify
```

**S3 access key (must be created in dashboard — no CLI path):**

1. Cloudflare dashboard → **R2 → Manage R2 API Tokens → Create API Token**
2. Token name: `ghorg-terraform-atlantis`
3. Permissions: **Object Read & Write**
4. Specify bucket: **Apply to specific buckets only → `ghorg-terraform-state`**
5. TTL: leave at "Forever" (or set to your preference)
6. Click **Create API Token** and save:
   - **Access Key ID** → use as `AWS_ACCESS_KEY_ID`
   - **Secret Access Key** → use as `AWS_SECRET_ACCESS_KEY`
   (The endpoint shown there matches the one above.)

### 2. Environment

Export in your devshell before running `terragrunt`:

```sh
export AWS_ACCESS_KEY_ID='<r2-access-key-from-dashboard>'
export AWS_SECRET_ACCESS_KEY='<r2-secret-key-from-dashboard>'
export TF_BACKEND_BUCKET='ghorg-terraform-state'
export TF_BACKEND_ENDPOINT='https://b22e4e9b05781ff42d6e61da16c57bdb.r2.cloudflarestorage.com'

# GitHub PATs (unchanged from before)
export GITHUB_TOKEN_DIVITMITTAL='<pat-with-repo-and-admin:org>'
export GITHUB_TOKEN_QEZTA='<pat-with-repo-and-admin:org>'
```

For permanence, drop these into `.envrc.local` (gitignored) and source it from `.envrc`.

### 3. Migrate state (per org, one-shot)

```sh
nix develop  # ensure terraform 1.10+ is in PATH
cd orgs/DivitMittal
terragrunt init -migrate-state   # answers "yes" when prompted
cd ../Qezta
terragrunt init -migrate-state
```

Terragrunt will copy each `orgs/<Org>/terraform.tfstate` into R2 under the key
`orgs/<Org>/terraform.tfstate`. After verifying with `terragrunt plan` (should be no-op), the local `terraform.tfstate` + backups can be deleted from the working tree.

### 4. Verify lockfile-based locking works

In one shell:

```sh
cd orgs/DivitMittal
terragrunt plan -lock-timeout=30s &
```

In another, immediately:

```sh
cd orgs/DivitMittal
terragrunt plan -lock-timeout=5s
```

The second should fail with `Error acquiring the state lock` — confirming R2 conditional-write locking is working.

## Phase 2 — cluster (TODO)

- `k3d cluster create` script + kustomize manifests under `k8s/atlantis/`.
- Atlantis Deployment, Service, ServiceAccount, ConfigMap, Secret.
- Cloudflare Tunnel Deployment for webhook ingress (`tunnel.cfargotunnel.com` → in-cluster Service).
- PVC mounted at `/home/atlantis/.nix-portable` for Nix-store caching across restarts.

## Phase 3 — webhook & first PR (TODO)

- Generate Atlantis webhook secret: `openssl rand -hex 32`.
- Register webhooks in both orgs (`Settings → Webhooks` → URL = tunnel URL + `/events`, content type `application/json`, secret as above, events: pull requests + pushes + issue comments).
- Open a noop PR (e.g. add a topic to a repo in `terranix/orgs/DivitMittal.nix`) → confirm Atlantis posts a plan comment.

## Image build

```sh
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  --tag ghcr.io/divitmittal/atlantis-terragrunt:dev \
  --load docker/atlantis
```

CI does this automatically on pushes to `main` that touch `docker/atlantis/**` (see `flake/actions/atlantis-image.nix`).

## Rollback

If R2 misbehaves and you need to fall back to local state quickly:

```sh
# In each org dir, with R2 env vars still set:
terragrunt state pull > terraform.tfstate

# Then revert root.hcl to backend = "local" and:
terragrunt init -migrate-state
```
