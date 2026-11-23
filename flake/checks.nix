{inputs, ...}: {
  imports = [inputs.git-hooks.flakeModule];

  perSystem = {
    pkgs,
    config,
    ...
  }: {
    ## Schema and secret-wiring invariants over every org's terranix output.
    checks.org-data =
      pkgs.runCommand "forge-org-data" {
        nativeBuildInputs = [(pkgs.python3.withPackages (ps: [ps.pytest]))];
        FORGE_LOCALS_GITHUB = config.packages.divitmittal-locals;
        FORGE_LOCALS_GITLAB = config.packages.divitmittal-gitlab-locals;
        FORGE_LOCALS_CODEBERG = config.packages.divitmittal-codeberg-locals;
        FORGE_LOCALS_GITEA = config.packages.divitmittal-gitea-locals;
        FORGE_LOCALS_SOURCEHUT = config.packages.divitmittal-sourcehut-locals;
        FORGE_REPO_ROOT = pkgs.lib.fileset.toSource {
          root = ../.;
          fileset = ../orgs/DivitMittal/terragrunt.hcl;
        };
      } ''
        ## A copy keeps pytest's rootdir out of /nix/store.
        cp ${../tests/test_org_data.py} test_org_data.py
        pytest -p no:cacheprovider -v test_org_data.py
        touch "$out"
      '';

    checks.github-state-encryption =
      pkgs.runCommand "github-state-encryption" {
        nativeBuildInputs = [pkgs.python3 pkgs.opentofu];
      } ''
        export HOME="$TMPDIR/home"
        mkdir -p "$HOME"
        python3 ${../tests/check-state-encryption.py} ${../orgs/DivitMittal/terragrunt.hcl}
        touch "$out"
      '';

    pre-commit = {
      check.enable = true;

      settings = {
        enable = true;
        package = pkgs.prek;
        gitPackage = pkgs.gitFull;
        src = ../.;
        excludes = ["flake.lock"];
        default_stages = ["pre-commit"];
        hooks = {
          ## Formatting
          treefmt.enable = false;
          trim-trailing-whitespace.enable = true;
          mixed-line-endings.enable = false;

          check-added-large-files = {
            enable = true;
            excludes = [
              ## Images
              "\\.png"
              "\\.jpg"
              "\\.jpeg"
              "\\.svg"
              "\\.gif"
            ];
          };
          check-case-conflicts.enable = true;
          check-executables-have-shebangs.enable = true;
          check-shebang-scripts-are-executable.enable = true;

          fix-byte-order-marker.enable = true;
          check-merge-conflicts.enable = true;
          detect-private-keys.enable = true;

          ## Shell
          shellcheck.enable = true;
        };
      };
    };
  };
}
