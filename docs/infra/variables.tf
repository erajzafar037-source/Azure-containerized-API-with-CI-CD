variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "project_name" {
  type    = string
  default = "fastapi-apprunner"
}

variable "github_repo" {
  type        = string
  description = "GitHub repo allowed to deploy, as owner/name (e.g. jane/aws-fastapi-cicd)."
}

variable "create_github_oidc_provider" {
  type        = bool
  default     = true
  description = "Set false if this AWS account already has the GitHub OIDC provider (only one is allowed per account)."
}

variable "deploy_service" {
  type        = bool
  default     = false
  description = "App Runner needs an image in ECR to start. Apply with false first, push an image via CI, then set true."
}

variable "alarm_email" {
  type        = string
  default     = ""
  description = "Optional email for 5xx alarm notifications."
}
