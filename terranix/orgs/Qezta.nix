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
    "ssh" = {
      description = "ssh divit@qezta.com — SSH terminal portfolio mirroring divit.qezta.com, built on wish + Bubble Tea";
      visibility = "public";
      topics = ["ssh" "tui" "go" "bubbletea" "wish"];
      delete_branch_on_merge = false;
      existing = false;
    };
    "ui" = {
      description = "Shared Svelte component library and design system for Qezta org sub-products";
      visibility = "public";
      topics = [];
      delete_branch_on_merge = false;
    };
  };

  locals.actions_environments = {
    ".github" = {
      production = {
        secrets = {};
        variables = {};
      };
    };

    "qezta-website" = {
      "Production – qezta-website-divit" = {
        secrets = {
          GH_TOKEN = "github";
          GEMINI_API_KEY = "gemini";
          GROQ_API_KEY = "groq";
          HF_TOKEN = "hf";
          OPENROUTER_API_KEY = "openrouter";
          OPENCODE_API_KEY = "opencode";
          DISCORD_TOKEN = "discord";
          GOOGLE_CLIENT_ID = "google_client_id";
          GOOGLE_CLIENT_SECRET = "google_client_secret";
          VERCEL_TOKEN = "vercel_token";
          VERCEL_ORG_ID = "vercel_org_id";
          VERCEL_PROJECT_ID = "vercel_project_id_qezta_website_divit";
        };
        variables = {};
      };

      "Production – qezta-website-qezta" = {
        secrets = {
          GH_TOKEN = "github";
          GEMINI_API_KEY = "gemini";
          GROQ_API_KEY = "groq";
          HF_TOKEN = "hf";
          OPENROUTER_API_KEY = "openrouter";
          OPENCODE_API_KEY = "opencode";
          DISCORD_TOKEN = "discord";
          GOOGLE_CLIENT_ID = "google_client_id";
          GOOGLE_CLIENT_SECRET = "google_client_secret";
          VERCEL_TOKEN = "vercel_token";
          VERCEL_ORG_ID = "vercel_org_id";
          VERCEL_PROJECT_ID = "vercel_project_id_qezta_website_qezta";
        };
        variables = {};
      };
    };
  };

  locals.protected_branches = {};
}
