## Terranix data module for the DivitMittal GitHub organisation.
## Compiled to `locals.tf.json` and consumed by `orgs/DivitMittal/main.tf`
## as `local.repos`. This file is the canonical source of truth for the
## DivitMittal repo list — edit here, then run `terragrunt plan`.
##
## Schema (per repo): description, homepage_url, visibility, topics,
## delete_branch_on_merge. Optional: archived, has_issues, existing.
## Sparse maps are intentional — the consuming module uses `try(...)` for
## absent keys, so omit fields that should fall back to their defaults.
_: let
  ## Archived repos share the same overrides; keep them DRY.
  mkArchived = base:
    base
    // {
      archived = true;
      has_issues = false;
    };
in {
  locals.repos = {
    ## ── Nix / Infrastructure ─────────────────────────────────────────────────

    "ghOrg-terraform" = {
      description = "Terraform project that declaratively manages the DivitMittal GitHub organization's repositories and branch protections via the GitHub provider";
      homepage_url = "https://deepwiki.com/DivitMittal/ghOrg-terraform";
      visibility = "public";
      topics = ["flake-parts" "github" "nix" "terraform" "terragrunt"];
      delete_branch_on_merge = true;
    };
    "OS-nixCfg" = {
      description = "nix (via nix-darwin, nixos, nix-on-droid, home-manager, etc.) declarative configurations to attain my deterministically reproducible layer";
      homepage_url = "https://deepwiki.com/DivitMittal/OS-nixCfg";
      visibility = "public";
      topics = ["agenix" "emacs" "flake-parts" "flakes" "home-manager" "neovim" "nix" "nix-darwin" "nix-on-droid" "nixos" "nixos-wsl"];
      delete_branch_on_merge = true;
    };
    "OS-nixCfg-secrets" = {
      description = "Secrets management repo for OS-nixCfg nix configuration";
      homepage_url = "https://deepwiki.com/DivitMittal/OS-nixCfg-secrets";
      visibility = "private";
      topics = ["agenix" "flake-parts" "nix" "secrets"];
      delete_branch_on_merge = true;
    };
    "ai-nixCfg" = {
      description = "Nix home-manager modules and configurations for AI coding assistants.";
      homepage_url = "https://deepwiki.com/DivitMittal/ai-nixCfg";
      visibility = "public";
      topics = ["ai" "ai-workflows" "claude-code" "flake" "flake-parts" "home-manager" "llms" "nix" "opencode"];
      delete_branch_on_merge = true;
    };
    "firefox-nixCfg" = {
      description = "A declarative Firefox configuration using Nix home-manager, designed for enhanced performance, a streamlined UI, and powerful automation";
      homepage_url = "https://deepwiki.com/DivitMittal/firefox-nixCfg";
      visibility = "public";
      topics = ["autoconfig" "betterfox" "css" "firefox" "flake-parts" "flakes" "javascript" "nix" "sideberry" "tridactyl"];
      delete_branch_on_merge = true;
    };
    "TermEmulator-Cfg" = {
      description = "Terminal emulator configurations for OS-nixCfg";
      homepage_url = "https://deepwiki.com/DivitMittal/TermEmulator-Cfg";
      visibility = "public";
      topics = ["flake" "flake-parts" "kitty" "nix" "terminal" "wezterm"];
      delete_branch_on_merge = true;
    };
    "Vim-Cfg" = {
      description = "Neovim & vim configurations for OS-nixCfg deployed via nix home-manager";
      homepage_url = "https://deepwiki.com/DivitMittal/Vim-Cfg";
      visibility = "public";
      topics = ["lazy-loading" "lua" "neovim" "nix" "nvchad" "nvim" "vim" "vimrc" "vimscript"];
      delete_branch_on_merge = true;
    };
    "Emacs-Cfg" = {
      description = "An elisp GNU Emacs configuration for Doom for OS-nixCfg via nix home-manager module, i.e., nix-doom-emacs-unstraightened";
      homepage_url = "https://deepwiki.com/DivitMittal/Emacs-Cfg";
      visibility = "public";
      topics = ["elisp" "emacs" "emacs-lisp" "flake" "flake-parts" "functional-programming" "nix"];
      delete_branch_on_merge = true;
    };
    "hammerspoon-nix" = {
      description = "A nix home-manager module for hammerspoon & my personal lua hammerspoon configuration";
      homepage_url = "https://deepwiki.com/DivitMittal/hammerspoon-nix";
      visibility = "public";
      topics = ["flake" "flake-parts" "hammerspoon" "lua" "nix"];
      delete_branch_on_merge = true;
    };
    "tidalcycles-nix" = {
      description = "Comprehensive standalone Nix flake providing a home-manager module for TidalCycles live coding environment";
      homepage_url = "https://deepwiki.com/DivitMittal/tidalcycles-nix";
      visibility = "public";
      topics = ["flake" "flake-parts" "haskell" "home-manager" "livecoding" "music" "nix" "supercollider" "tidalcycles"];
      delete_branch_on_merge = true;
    };

    ## ── AI / Machine Learning ────────────────────────────────────────────────

    "DocAssist-LLM" = {
      description = "RAG-enhanced LLaMa-like transformer neural network based LLM for assistance on programming languages/frameworks' documentations.";
      homepage_url = "https://deepwiki.com/DivitMittal/DocAssist-LLM";
      visibility = "public";
      topics = ["artifical-intelligense" "deep-learning" "flake-parts" "llama" "llm" "nix" "pytorch" "rag" "transformers"];
      delete_branch_on_merge = true;
    };
    "CARLA-Autonomous-Driving" = {
      description = "Via high-fidelity CARLA vehicle simulator & deep semantic segmentation, data from RGBA cameras and LiDAR sensors are combined to achieve comprehensive environmental awareness";
      homepage_url = "https://deepwiki.com/DivitMittal/CARLA-Autonomous-Driving";
      visibility = "public";
      topics = ["autonoumous-driving" "carla-simulator" "deep-learning" "pygame" "semantic-segmentation"];
      delete_branch_on_merge = true;
    };
    "Driver-Drowsiness-Detection" = {
      description = "Real-time drowsiness detection on driver's face continuously for signs of fatigue using deep learning methodologies";
      homepage_url = "https://deepwiki.com/DivitMittal/Driver-Drowsiness-Detection";
      visibility = "public";
      topics = ["computer-vision" "deep-learning" "drowsiness-detection" "siamese-neural-network"];
      delete_branch_on_merge = true;
    };
    "HybridTransformer-MFIF" = {
      description = "Implementing Focal Transformer & CrossViT Hybrid for MFIF";
      homepage_url = "https://deepwiki.com/DivitMittal/HybridTransformer-MFIF";
      visibility = "private";
      topics = ["computer-vision" "crossvit" "deep-learning" "focal-transformer" "image-fusion" "transformers"];
      delete_branch_on_merge = true;
    };
    "CUDA-Transformer" = {
      description = "CUDA-accelerated transformer implementation";
      homepage_url = "https://deepwiki.com/DivitMittal/CUDA-Transformer";
      visibility = "private";
      topics = ["cuda" "deep-learning" "diabetic-retinopathy-detection" "transformer"];
      delete_branch_on_merge = true;
    };
    "LLM-feeder" = {
      description = "Multiple-choice questions (MCQs) are parsed, & the question is sent to a Large Language Model (LLM) to obtain an answer";
      homepage_url = "https://deepwiki.com/DivitMittal/LLM-feeder";
      visibility = "private";
      topics = ["llm" "mcq" "nlp" "python" "question-answering"];
      delete_branch_on_merge = true;
    };
    "ZestaAds" = {
      description = "Generative AI ad network with personalized, UI-integrated ads via API.";
      homepage_url = "https://deepwiki.com/DivitMittal/ZestaAds";
      visibility = "public";
      topics = ["advertising" "ai" "concept" "genai" "ideation" "marketing" "prototype"];
      delete_branch_on_merge = true;
    };
    "Zesta-Car-App" = {
      description = "Swift license plate recognition deep learning model with a cross-platform (mobile, web) front-end to obtain info. pertaining to the vehicle in real-time.";
      homepage_url = "https://deepwiki.com/DivitMittal/Zesta-Car-App";
      visibility = "public";
      topics = ["computer-vision" "deep-learning" "expo" "nodejs" "ocr-recognition" "react-native"];
      delete_branch_on_merge = true;
    };
    "Blinkit-Churn-Analysis" = {
      description = "Analyzing customer attrition & strategies to reduce churn via AutoML techniques & PowerBI";
      homepage_url = "https://deepwiki.com/DivitMittal/Blinkit-Churn-Analysis";
      visibility = "public";
      topics = ["churn-analysis" "dashboards" "h2oai" "powerbi" "sweetviz"];
      delete_branch_on_merge = true;
    };
    "Datathon-BigData" = {
      description = "Efficient Data Processing ETL Pipeline for Event Records";
      homepage_url = "https://deepwiki.com/DivitMittal/Datathon-BigData";
      visibility = "public";
      topics = ["aws" "aws-glue" "aws-lambda" "aws-s3" "etl-pipeline" "hadoop" "spark"];
      delete_branch_on_merge = true;
    };

    ## ── Personal Tools / Projects ────────────────────────────────────────────

    "TLTR" = {
      description = "Cross-platform multi-layer keyboard layout tailored for programmers";
      homepage_url = "https://deepwiki.com/DivitMittal/TLTR";
      visibility = "public";
      topics = ["developer-productivity" "ergonomic-keyboard" "kanata" "karabiner-elements" "keyboard" "keyboard-layout" "keymap-drawer" "qmk" "raspberry-pi-pico" "split-keyboard" "tltr"];
      delete_branch_on_merge = true;
    };
    "PKMS" = {
      description = "A Personal Knowledge Management System in Obsidian-style markdown following the Zettelkasten method";
      homepage_url = "https://deepwiki.com/DivitMittal/PKMS";
      visibility = "public";
      topics = ["flake-parts" "kms" "markdown" "nix" "obsidian" "pkms" "second-brain" "wiki" "zettelkasten"];
      delete_branch_on_merge = true;
    };
    "MeriNetWorth" = {
      description = "Bank account consolidation system with multi-format statement extraction and visual analytics dashboard";
      homepage_url = "https://deepwiki.com/DivitMittal/MeriNetWorth";
      visibility = "public";
      topics = ["dashboard" "flake" "flake-parts" "nix" "python" "streamlit" "uv"];
      delete_branch_on_merge = true;
    };
    "Lagrangian-Reconstruction" = {
      description = "Go implementation of Shamir's Secret Sharing via Lagrange interpolation for polynomial reconstruction.";
      homepage_url = "https://deepwiki.com/DivitMittal/Lagrangian-Reconstruction";
      visibility = "public";
      topics = ["direnv" "flakes" "golang" "lagrange-polynomial-interpolation" "nix" "shamir-secret-sharing"];
      delete_branch_on_merge = true;
    };
    "hs-faust" = {
      description = "Haskell DSL wrapper for writing DSP files utilizing the Faust's Signal API & Compiler";
      homepage_url = "https://deepwiki.com/DivitMittal/hs-faust";
      visibility = "public";
      topics = ["compilers" "dsl" "flake-parts" "functional-programming" "nix"];
      delete_branch_on_merge = true;
    };
    "professionalstay-site" = {
      description = "Professional Stay Homepage";
      homepage_url = "https://deepwiki.com/DivitMittal/professionalstay-site";
      visibility = "public";
      topics = ["nextjs" "nix" "reactjs" "shadcn-ui" "tailwindcss"];
      delete_branch_on_merge = true;
    };
    "mcp-kaggle-tool" = {
      description = "MCP server for Kaggle API integration - create, run, and manage Kaggle notebooks programmatically";
      homepage_url = "https://deepwiki.com/DivitMittal/mcp-kaggle-tool";
      visibility = "public";
      topics = ["kaggle" "mcp" "mcp-server" "notebooks" "python"];
      delete_branch_on_merge = true;
    };
    "AudioResSwitcher-Raycast" = {
      description = "Control audio quality with precision. Switch sample rates, bit depth, and formats for input/output devices. Monitor current bitrate in menubar.";
      homepage_url = "https://deepwiki.com/DivitMittal/AudioResSwitcher-Raycast";
      visibility = "public";
      topics = ["audio" "macos" "menubar" "raycast" "raycast-extension" "swift"];
      delete_branch_on_merge = true;
    };

    ## ── Dotfiles / Sync ──────────────────────────────────────────────────────

    "sync-windows" = {
      description = "~/.* (Windows)";
      homepage_url = "https://deepwiki.com/DivitMittal/sync-windows";
      visibility = "public";
      topics = ["dotfiles" "dotfiles-windows" "flake-parts" "nix" "powershell" "windows-10" "windows-11" "flake-parts" "flakes" "nix"];
      delete_branch_on_merge = false;
    };
    "playbooks-4-windows" = {
      description = "Ansible playbooks for Windows configuration management";
      homepage_url = "https://deepwiki.com/DivitMittal/playbooks-4-windows";
      visibility = "public";
      topics = ["ansible" "ansible-playbook" "windows" "windows-10" "windows-11" "nix" "flake-parts" "flakes"];
      delete_branch_on_merge = true;
    };

    ## ── Profile / Meta ───────────────────────────────────────────────────────

    "DivitMittal-CV" = {
      description = "Curriculum Vitae — LaTeX source, compiled PDFs, markdown fragments for AI agents, and Claude Code configuration; tooling managed by flake-parts with a Nix devshell providing the TeX Live environment";
      homepage_url = "https://deepwiki.com/DivitMittal/DivitMittal-CV";
      visibility = "private";
      topics = ["claude-code" "cv" "flake-parts" "latex" "markdown" "nix" "pdf" "resume" "texlive"];
      delete_branch_on_merge = true;
    };
    "DivitMittal" = {
      description = "Repository to setup GitHub profile.";
      homepage_url = "https://deepwiki.com/DivitMittal/DivitMittal";
      visibility = "public";
      topics = ["html" "information" "markdown" "profile" "profile-readme" "stats"];
      delete_branch_on_merge = false;
    };
    "awesome" = {
      description = "Personal Awesome list";
      homepage_url = "https://deepwiki.com/DivitMittal/awesome";
      visibility = "public";
      topics = ["awesome-lists" "floss" "foss" "github" "sourcehut"];
      delete_branch_on_merge = false;
    };

    ## ── Archived ─────────────────────────────────────────────────────────────

    "kanata-service" = mkArchived {
      description = "A macOS launchctl wrapper to run Kanata (keyboard remapper) on startup/load as a daemon.";
      homepage_url = "https://deepwiki.com/DivitMittal/kanata-service";
      visibility = "public";
      topics = ["bash" "kanata" "launchctl" "plist"];
      delete_branch_on_merge = false;
    };
    "sync-android" = mkArchived {
      description = "~/.* (Android)";
      homepage_url = "https://deepwiki.com/DivitMittal/sync-android";
      visibility = "public";
      topics = ["android" "dotfiles" "dotfiles-android" "flake-parts" "nix"];
      delete_branch_on_merge = false;
    };
    "sync-macOS" = mkArchived {
      description = "Contains all dotfiles, config files, package-manager bundles, shell scripts, preferences files, etc., to setup macOS.";
      homepage_url = "https://deepwiki.com/DivitMittal/sync-macOS";
      visibility = "public";
      topics = ["config" "doom" "dotfiles" "dotfiles-macos" "emacs" "mackup" "nvim" "raycast" "skhd" "vim" "yabai"];
      delete_branch_on_merge = false;
    };
    "git-fun" = mkArchived {
      description = "My first app on GitHub!";
      homepage_url = "https://deepwiki.com/DivitMittal/git-fun";
      visibility = "public";
      topics = [];
      delete_branch_on_merge = false;
    };
    "employee-management" = mkArchived {
      description = "Flutter employee management cross-platform app";
      homepage_url = "https://deepwiki.com/DivitMittal/employee-management";
      visibility = "public";
      topics = ["android" "cross-platform" "dart" "employee-management" "flutter" "ios"];
      delete_branch_on_merge = false;
    };
  };
}
