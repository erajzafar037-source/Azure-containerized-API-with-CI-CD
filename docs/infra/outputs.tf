output "ecr_repository_url" {
  value = aws_ecr_repository.app.repository_url
}

output "github_actions_role_arn" {
  description = "Set as the AWS_ROLE_ARN repository variable in GitHub."
  value       = aws_iam_role.github_actions.arn
}

output "service_url" {
  description = "Set as the SERVICE_URL repository variable in GitHub (hostname only)."
  value       = try(aws_apprunner_service.app[0].service_url, "not deployed yet")
}

output "alerts_topic_arn" {
  value = aws_sns_topic.alerts.arn
}
