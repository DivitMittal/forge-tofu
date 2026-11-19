{
  inputs,
  lib,
  ...
}: {
  imports = [inputs.devshell.flakeModule];

  perSystem = {
    pkgs,
    config,
    ...
  }: {
    devshells.default = {
      devshell = rec {
        name = "forge-tofu";
        motd = "{202}Welcome to {91}${name} {202}devshell!{reset} \n $(menu)";
        startup = {
          git-hooks.text = ''
            ${config.pre-commit.installationScript}
          '';
        };
        packages =
          lib.attrsets.attrValues {
            inherit
              (pkgs)
              ### LSPs & Formatters
              ## Nix
              nixd
              alejandra
              ## CLI tools
              opentofu
              terraform-mcp-server
              terragrunt
              ## Forge CLIs, one per provider, for manual API calls,
              ## verification and token minting
              gh # GitHub
              glab # GitLab
              tea # Gitea instances (Codeberg, gitea.com)
              hut # SourceHut
              ;
          }
          ++ [inputs.agenix.packages.${pkgs.stdenv.hostPlatform.system}.default];
      };
    };
  };
}
