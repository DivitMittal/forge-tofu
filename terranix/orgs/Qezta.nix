## Terranix data module for the Qezta GitHub organisation.
## Compiled to `locals.tf.json` and consumed by `orgs/Qezta/main.tf`
## as `local.repos` and `local.protected_branches`.
_: {
  locals.repos = {
    ".github" = {
      description = "Qezta org profile";
      visibility = "public";
      topics = ["profile"];
      delete_branch_on_merge = false;
    };
    "divit" = {
      description = "divit.qezta.com — personal portfolio with Gemini-powered RAG chatbot";
      visibility = "public";
      topics = [];
      delete_branch_on_merge = false;
    };
    "qezta-website" = {
      description = "Qezta Website";
      homepage_url = "https://www.Qezta.com";
      visibility = "public";
      topics = ["flake-parts" "nix" "personal-website" "svelte" "typescript" "vercel-deployment" "vite"];
      delete_branch_on_merge = false;
    };
    "site" = {
      description = "qezta.com — marketing site for Qezta";
      visibility = "public";
      topics = [];
      delete_branch_on_merge = false;
    };
    "ui" = {
      description = "Shared Svelte component library and design system for Qezta org sub-products";
      visibility = "public";
      topics = [];
      delete_branch_on_merge = false;
    };
  };

  locals.protected_branches = {};
}
