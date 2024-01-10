resource "aws_cloudwatch_log_group" "ecs_log_group" {
  name = "/ecs/ecs-log-group"

  retention_in_days = 30  
  tags = {
    Name = "ECSLogs"
  }
}

resource "aws_cloudwatch_metric_alarm" "high_latency" {
  alarm_name          = "high-latency-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "TargetResponseTime"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  statistic           = "Average"
  threshold           = 0.300  # 300 milliseconds
  alarm_description   = "Alarm when target response time exceeds 300ms"
  actions_enabled     = true

  dimensions = {
    LoadBalancer = aws_lb.alb.arn
  }
}

resource "aws_cloudwatch_metric_alarm" "high_error_rate" {
  alarm_name          = "high-error-rate-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "HTTPCode_ELB_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  statistic           = "Sum"
  threshold           = 10  # Adjust the threshold based on your requirements
  alarm_description   = "Alarm when the number of HTTP 5XX errors exceeds the threshold"
  actions_enabled     = true

  dimensions = {
    LoadBalancer = aws_lb.alb.arn
  }
}