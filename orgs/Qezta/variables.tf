variable "github_token" {
  description = "GitHub PAT for the Qezta org. Injected by Terragrunt from GITHUB_TOKEN_QEZTA or GITHUB_TOKEN."
  type        = string
  sensitive   = true
}
