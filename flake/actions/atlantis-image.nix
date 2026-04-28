_: {
  flake.actions-nix.workflows.".github/workflows/atlantis-image.yml" = {
    on = {
      push = {
        branches = ["main"];
        paths = [
          "docker/atlantis/**"
          "flake/actions/atlantis-image.nix"
        ];
      };
      pull_request = {
        paths = [
          "docker/atlantis/**"
          "flake/actions/atlantis-image.nix"
        ];
      };
      workflow_dispatch = {};
    };
    jobs.build-and-push = {
      permissions = {
        contents = "read";
        packages = "write";
        id-token = "write";
      };
      steps = [
        {
          name = "Checkout repo";
          uses = "actions/checkout@main";
          "with" = {
            fetch-depth = 1;
            persist-credentials = false;
          };
        }
        {
          name = "Set up QEMU";
          uses = "docker/setup-qemu-action@v3";
        }
        {
          name = "Set up Docker Buildx";
          uses = "docker/setup-buildx-action@v3";
        }
        {
          name = "Log in to GHCR";
          uses = "docker/login-action@v3";
          "with" = {
            registry = "ghcr.io";
            username = "\${{ github.actor }}";
            password = "\${{ secrets.GITHUB_TOKEN }}";
          };
        }
        {
          name = "Compute image metadata";
          id = "meta";
          uses = "docker/metadata-action@v5";
          "with" = {
            images = "ghcr.io/\${{ github.repository_owner }}/atlantis-terragrunt";
            tags = ''
              type=sha,format=long
              type=ref,event=branch
              type=ref,event=pr
              type=raw,value=latest,enable={{is_default_branch}}
            '';
          };
        }
        {
          name = "Build and push";
          uses = "docker/build-push-action@v6";
          "with" = {
            context = "docker/atlantis";
            file = "docker/atlantis/Dockerfile";
            platforms = "linux/amd64,linux/arm64";
            push = "\${{ github.event_name != 'pull_request' }}";
            tags = "\${{ steps.meta.outputs.tags }}";
            labels = "\${{ steps.meta.outputs.labels }}";
            cache-from = "type=gha";
            cache-to = "type=gha,mode=max";
          };
        }
      ];
    };
  };
}
