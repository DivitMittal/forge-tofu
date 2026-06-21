# Security Policy

## Scope

This repository declaratively manages GitHub organisations via Terraform + Terragrunt. The relevant attack surface includes:

- **GitHub PATs** (`GITHUB_TOKEN_DIVITMITTAL`, `GITHUB_TOKEN_QEZTA`) — referenced as environment variables, never committed
- **Branch protection rules** — misconfiguration here could weaken repository security across managed orgs
- **Terraform state** (`orgs/*/terraform.tfstate`) — contains resource metadata; gitignored and never committed

## Reporting a Vulnerability

If you find a security issue (e.g. a configuration that could expose credentials or unintentionally weaken org security):

1. Open a **GitHub issue** with the label `security`.
2. Include a description, reproduction steps, and impact assessment.

## Out of Scope

- Issues in the upstream `hashicorp/github` Terraform provider (report upstream)
- GitHub platform security issues (report to GitHub directly)

## Supported Versions

Only the latest commit on `main` is supported.
