"""Schema and cross-file invariants for the terranix org data (terranix/orgs/*.nix).

The repositories module only checks descriptions and workflow_permissions at
plan time, which needs a token and the state passphrase. These run in the
sandbox, and also cover what plan can't see: the Actions secret map in
terranix has to agree with the age sources decrypted by
orgs/DivitMittal/terragrunt.hcl.

Paths come from the flake check: FORGE_LOCALS_<ORG> per org, FORGE_REPO_ROOT.
"""
import json
import os
import pathlib
import re

import pytest

ORGS = {
    "github": ("FORGE_LOCALS_GITHUB", {"public", "private"}),
    "gitlab": ("FORGE_LOCALS_GITLAB", {"public", "private", "internal"}),
    "codeberg": ("FORGE_LOCALS_CODEBERG", {"public", "private"}),
    "gitea": ("FORGE_LOCALS_GITEA", {"public", "private"}),
    "sourcehut": ("FORGE_LOCALS_SOURCEHUT", {"public", "private", "unlisted"}),
}
ALLOWED_KEYS = {
    "description", "homepage_url", "visibility", "topics", "delete_branch_on_merge",
    "archived", "has_issues", "existing", "workflow_permissions", "actions_can_create_prs",
}
TOPIC = re.compile(r"^[a-z0-9][a-z0-9-]{0,49}$")  # GitHub's topic rule
REPO_NAME = re.compile(r"^[A-Za-z0-9._-]{1,100}$")
SECRET_NAME = re.compile(r"^[A-Z][A-Z0-9_]*$")


def _env(var):
    value = os.environ.get(var)
    if not value:
        pytest.skip(f"{var} not set (run via `nix flake check`)")
    return value


def locals_for(org):
    with open(_env(ORGS[org][0])) as f:
        return json.load(f)["locals"]


@pytest.fixture(scope="module")
def github():
    return locals_for("github")


@pytest.fixture(scope="module")
def secret_sources():
    """Uncommented keys of `actions_secret_sources` in orgs/DivitMittal/terragrunt.hcl."""
    hcl = (pathlib.Path(_env("FORGE_REPO_ROOT")) / "orgs/DivitMittal/terragrunt.hcl").read_text()
    block = re.search(r"actions_secret_sources\s*=\s*\{(.*?)\n  \}", hcl, re.S)
    assert block, "actions_secret_sources block not found in terragrunt.hcl"
    sources = {}
    for line in block.group(1).splitlines():
        m = re.match(r'\s*([a-z0-9_]+)\s*=\s*"([^"]+)"', line)  # commented lines start with '#'
        if m:
            sources[m.group(1)] = m.group(2)
    return sources


# ------------------------------------------------------------ every forge


@pytest.mark.parametrize("org", ORGS)
def test_repo_schema(org):
    repos = locals_for(org).get("repos", {})
    visibilities = ORGS[org][1]
    for name, r in repos.items():
        assert REPO_NAME.match(name), f"{org}/{name}: invalid repository name"
        assert not set(r) - ALLOWED_KEYS, f"{org}/{name}: unknown keys {set(r) - ALLOWED_KEYS} (typo?)"
        assert r.get("visibility") in visibilities, f"{org}/{name}: visibility {r.get('visibility')!r}"
        if not r.get("archived"):
            assert (r.get("description") or "").strip(), f"{org}/{name}: active repo without description"
        if "homepage_url" in r:
            assert r["homepage_url"].startswith("https://"), f"{org}/{name}: homepage must be https"


@pytest.mark.parametrize("org", ORGS)
def test_repo_names_unique_case_insensitively(org):
    # Forges treat names case-insensitively; two keys differing in case collide on apply.
    names = [n.lower() for n in locals_for(org).get("repos", {})]
    assert len(names) == len(set(names))


# ------------------------------------------------------------ GitHub repos


def test_github_topics_follow_github_rules(github):
    for name, r in github["repos"].items():
        topics = r.get("topics", [])
        assert len(topics) <= 20, f"{name}: GitHub allows at most 20 topics"
        assert len(topics) == len(set(topics)), f"{name}: duplicate topics"
        bad = [t for t in topics if not TOPIC.match(t)]
        assert not bad, f"{name}: invalid topics {bad}"


def test_github_workflow_settings(github):
    for name, r in github["repos"].items():
        assert r.get("workflow_permissions", "read") in {"read", "write"}, name
        assert isinstance(r.get("actions_can_create_prs", True), bool), name
        assert isinstance(r["delete_branch_on_merge"], bool), name


def test_archived_repos_disable_issues(github):
    for name, r in github["repos"].items():
        if r.get("archived"):
            assert r.get("has_issues") is False, f"{name}: archived repos are read-only; issues just collect noise"


# ------------------------------------------------------------ Actions environments


def environments(github):
    for repo, envs in github.get("actions_environments", {}).items():
        for env, cfg in envs.items():
            yield repo, env, cfg


def test_environments_target_active_managed_repos(github):
    for repo, env, _ in environments(github):
        assert repo in github["repos"], f"{repo}:{env}: repo not managed by forge-tofu"
        assert not github["repos"][repo].get("archived"), f"{repo}:{env}: repo is archived"


def test_secret_and_variable_names(github):
    for repo, env, cfg in environments(github):
        for name in [*cfg.get("secrets", {}), *cfg.get("pending_secrets", {}), *cfg.get("variables", {})]:
            assert SECRET_NAME.match(name), f"{repo}:{env}: {name} is not UPPER_SNAKE_CASE"
            assert not name.startswith("GITHUB_"), f"{repo}:{env}: GitHub rejects names starting with GITHUB_"


def test_pending_entries_are_not_also_active(github):
    for repo, env, cfg in environments(github):
        both = set(cfg.get("secrets", {})) & set(cfg.get("pending_secrets", {}))
        assert not both, f"{repo}:{env}: {both} both active and pending"
        both = set(cfg.get("variables", {})) & set(cfg.get("pending_variables", []))
        assert not both, f"{repo}:{env}: {both} both active and pending"


def test_existing_variables_are_declared_somewhere(github):
    # main.tf only imports existing_variables that are also in `variables`; anything else is a typo.
    for repo, env, cfg in environments(github):
        known = set(cfg.get("variables", {})) | set(cfg.get("pending_variables", []))
        stray = set(cfg.get("existing_variables", [])) - known
        assert not stray, f"{repo}:{env}: existing_variables {stray} not in variables/pending_variables"


def test_every_active_secret_has_an_age_source(github, secret_sources):
    # Otherwise plan fails in modules/actions-environments with missing_secret_sources.
    for repo, env, cfg in environments(github):
        for name, source in cfg.get("secrets", {}).items():
            assert source in secret_sources, (
                f"{repo}:{env}:{name} uses source {source!r}, which is not enabled in "
                "actions_secret_sources (orgs/DivitMittal/terragrunt.hcl)"
            )


def test_pending_secrets_have_no_enabled_source(github, secret_sources):
    # Enabling a source while its secret is still pending decrypts a file nothing uses.
    for repo, env, cfg in environments(github):
        for name, source in cfg.get("pending_secrets", {}).items():
            assert source not in secret_sources, f"{repo}:{env}:{name}: source enabled but secret still pending"


def test_every_enabled_source_is_used(github, secret_sources):
    used = {s for _, _, cfg in environments(github) for s in cfg.get("secrets", {}).values()}
    unused = set(secret_sources) - used
    assert not unused, f"actions_secret_sources decrypts unused secrets: {unused}"


def test_secret_sources_are_age_files(secret_sources):
    for key, path in secret_sources.items():
        assert path.endswith(".age") and not path.startswith("/") and ".." not in path, f"{key}: {path}"
