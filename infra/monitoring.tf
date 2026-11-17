# App Runner ships application stdout/stderr to CloudWatch Logs automatically
# (/aws/apprunner/<service>/<id>/application) and publishes metrics to AWS/AppRunner.

resource "aws_sns_topic" "alerts" {
  name = "${var.project_name}-alerts"
}

resource "aws_sns_topic_subscription" "email" {
  count     = var.alarm_email == "" ? 0 : 1
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alarm_email
}

resource "aws_cloudwatch_metric_alarm" "http_5xx" {
  count = var.deploy_service ? 1 : 0

  alarm_name          = "${var.project_name}-5xx"
  alarm_description   = "More than 5 server errors in 5 minutes"
  namespace           = "AWS/AppRunner"
  metric_name         = "5xxStatusResponses"
  statistic           = "Sum"
  period              = 300
  evaluation_periods  = 1
  threshold           = 5
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "notBreaching"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    ServiceName = aws_apprunner_service.app[0].service_name
    ServiceID   = aws_apprunner_service.app[0].service_id
  }
}
