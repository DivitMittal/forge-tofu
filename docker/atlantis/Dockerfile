# syntax=docker/dockerfile:1.7
# ---------------------------------------------------------------------------
# Custom Atlantis image: upstream Atlantis + Terragrunt + nix-portable.
#
# nix-portable (https://github.com/DavHau/nix-portable) is a single-binary,
# rootless Nix runtime — used here because the upstream Atlantis image runs
# as a non-root `atlantis` user, which makes a multi-user Nix daemon install
# painful. nix-portable bootstraps to $HOME/.nix-portable on first invocation;
# mount a PVC there in the cluster manifests to cache the Nix store across
# pod restarts.
#
# Build (multi-arch):
#   docker buildx build \
#     --platform linux/amd64,linux/arm64 \
#     --tag ghcr.io/divitmittal/atlantis-terragrunt:latest \
#     --push docker/atlantis
# ---------------------------------------------------------------------------

# Pin to match the devshell-provided versions so plan output matches what you
# see locally. Bump deliberately, not by accident.
ARG ATLANTIS_VERSION=v0.30.0
ARG TERRAGRUNT_VERSION=v1.0.4
ARG NIX_PORTABLE_VERSION=v013

FROM ghcr.io/runatlantis/atlantis:${ATLANTIS_VERSION}

ARG TERRAGRUNT_VERSION
ARG NIX_PORTABLE_VERSION
ARG TARGETARCH

USER root

RUN set -eux; \
    case "${TARGETARCH}" in \
      amd64) tg_arch=amd64 ; np_arch=x86_64  ;; \
      arm64) tg_arch=arm64 ; np_arch=aarch64 ;; \
      *) echo "unsupported arch: ${TARGETARCH}" >&2; exit 1 ;; \
    esac; \
    apk add --no-cache curl ca-certificates bash xz; \
    curl -fsSL -o /usr/local/bin/terragrunt \
      "https://github.com/gruntwork-io/terragrunt/releases/download/${TERRAGRUNT_VERSION}/terragrunt_linux_${tg_arch}"; \
    chmod +x /usr/local/bin/terragrunt; \
    curl -fsSL -o /usr/local/bin/nix-portable \
      "https://github.com/DavHau/nix-portable/releases/download/${NIX_PORTABLE_VERSION}/nix-portable-${np_arch}"; \
    chmod +x /usr/local/bin/nix-portable

# Wrapper so terragrunt's `nix build ...` calls in generate{} blocks transparently
# hit nix-portable instead of failing with "nix: not found".
RUN printf '#!/bin/sh\nexec /usr/local/bin/nix-portable nix "$@"\n' > /usr/local/bin/nix && \
    chmod +x /usr/local/bin/nix

USER atlantis

# HOME is set so nix-portable can bootstrap to $HOME/.nix-portable on first
# invocation. Mount a PVC at /home/atlantis/.nix-portable in k8s to persist
# the Nix store across pod restarts. NP_RUNTIME is left unset so nix-portable
# auto-selects bwrap/proot based on what the host kernel allows.
ENV HOME=/home/atlantis

# Build-time smoke test: only test binaries that don't trigger the
# nix-portable bootstrap (which would balloon the image with the Nix store).
RUN terragrunt --version && terraform --version
