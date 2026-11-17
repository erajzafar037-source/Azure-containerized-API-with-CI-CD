resource "aws_apprunner_auto_scaling_configuration_version" "app" {
  count = var.deploy_service ? 1 : 0

  auto_scaling_configuration_name = "${var.project_name}-asc"
  min_size                        = 1
  max_size                        = 2
  max_concurrency                 = 50
}

resource "aws_apprunner_service" "app" {
  count = var.deploy_service ? 1 : 0

  service_name                   = var.project_name
  auto_scaling_configuration_arn = aws_apprunner_auto_scaling_configuration_version.app[0].arn

  source_configuration {
    # Pushing a new :latest to ECR triggers a new deployment automatically.
    auto_deployments_enabled = true

    authentication_configuration {
      access_role_arn = aws_iam_role.apprunner_access.arn
    }

    image_repository {
      image_identifier      = "${aws_ecr_repository.app.repository_url}:latest"
      image_repository_type = "ECR"

      image_configuration {
        port = "8000"

        # Injected at runtime from Secrets Manager; never in the image or the repo.
        runtime_environment_secrets = {
          APP_SECRET = aws_secretsmanager_secret.app.arn
        }
      }
    }
  }

  instance_configuration {
    cpu               = "256"
    memory            = "512"
    instance_role_arn = aws_iam_role.apprunner_instance.arn
  }

  health_check_configuration {
    protocol            = "HTTP"
    path                = "/health"
    interval            = 10
    timeout             = 5
    healthy_threshold   = 1
    unhealthy_threshold = 5
  }

  depends_on = [
    aws_iam_role_policy_attachment.apprunner_access_ecr,
    aws_iam_role_policy.apprunner_instance,
    aws_secretsmanager_secret_version.app,
  ]
}
