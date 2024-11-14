# us-east-1


# CloudWatch Alarm for CPU Utilization to Trigger Scaling Up in us-east-1

resource "aws_cloudwatch_metric_alarm" "scale_up_cpu_utilization" {
  alarm_name          = "ScaleUpCPUUtilizationAlarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "This alarm triggers if CPU utilization exceeds 80% to scale up."
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.app_asg.name
  }
  actions_enabled = true
  alarm_actions   = [aws_autoscaling_policy.scale_up.arn, aws_sns_topic.alert_topic.arn]  
}

# CloudWatch Alarm for CPU Utilization to Trigger Scaling Down in us-east-1

resource "aws_cloudwatch_metric_alarm" "scale_down_cpu_utilization" {
  alarm_name          = "ScaleDownCPUUtilizationAlarm"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 30
  alarm_description   = "This alarm triggers if CPU utilization drops below 30% to scale down."
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.app_asg.name
  }
  actions_enabled = true
  alarm_actions   = [aws_autoscaling_policy.scale_down.arn, aws_sns_topic.alert_topic.arn]  
}



# CloudWatch Alarm for Memory Utilization

resource "aws_cloudwatch_metric_alarm" "high_memory_utilization" {
  alarm_name          = "HighMemoryUtilizationAlarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "mem_used_percent"
  namespace           = "CWAgent"
  period              = 300
  statistic           = "Average"
  threshold           = 80  # Set threshold based on your requirements
  alarm_description   = "This alarm triggers if memory utilization exceeds 80%."
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.app_asg.name
  }
  actions_enabled     = true
  alarm_actions       = [aws_sns_topic.alert_topic.arn]  
}

# CloudWatch Alarm for Disk Utilization

resource "aws_cloudwatch_metric_alarm" "high_disk_utilization" {
  alarm_name          = "HighDiskUtilizationAlarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "disk_used_percent"
  namespace           = "CWAgent"
  period              = 300
  statistic           = "Average"
  threshold           = 80  # Set threshold based on your requirements
  alarm_description   = "This alarm triggers if disk utilization exceeds 80%."
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.app_asg.name
  }
  actions_enabled     = true
  alarm_actions       = [aws_sns_topic.alert_topic.arn]  
}

# SNS Topic for Alarm Notifications in us-east-1

resource "aws_sns_topic" "alert_topic" {
  name = "EC2AlertTopic"
}

resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.alert_topic.arn
  protocol  = "email"
  endpoint  = var.notification_email  
}



# us-west-2

# CloudWatch Alarm for CPU Utilization to Trigger Scaling Up in us-west-2

resource "aws_cloudwatch_metric_alarm" "west_scale_up_cpu_utilization" {
  provider            = aws.west
  alarm_name          = "WestScaleUpCPUUtilizationAlarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "This alarm triggers if CPU utilization exceeds 80% to scale up."
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.secondary_asg.name
  }
  actions_enabled = true
  alarm_actions   = [aws_autoscaling_policy.west_scale_up.arn, aws_sns_topic.west_alert_topic.arn]  
}

# CloudWatch Alarm for CPU Utilization to Trigger Scaling Down in us-west-2

resource "aws_cloudwatch_metric_alarm" "west_scale_down_cpu_utilization" {
  provider            = aws.west
  alarm_name          = "WestScaleDownCPUUtilizationAlarm"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 30
  alarm_description   = "This alarm triggers if CPU utilization drops below 30% to scale down."
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.secondary_asg.name
  }
  actions_enabled = true
  alarm_actions   = [aws_autoscaling_policy.west_scale_down.arn, aws_sns_topic.west_alert_topic.arn]  
}


# CloudWatch Alarm for Memory Utilization in us-west-2

resource "aws_cloudwatch_metric_alarm" "west_high_memory_utilization" {
  provider            = aws.west
  alarm_name          = "WestHighMemoryUtilizationAlarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "mem_used_percent"
  namespace           = "CWAgent"
  period              = 300
  statistic           = "Average"
  threshold           = 80  # Set threshold based on your requirements
  alarm_description   = "This alarm triggers if memory utilization exceeds 80%."
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.secondary_asg.name
  }
  actions_enabled     = true
  alarm_actions       = [aws_sns_topic.west_alert_topic.arn] 
}

# CloudWatch Alarm for Disk Utilization in us-west-2

resource "aws_cloudwatch_metric_alarm" "west_high_disk_utilization" {
  provider            = aws.west
  alarm_name          = "WestHighDiskUtilizationAlarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "disk_used_percent"
  namespace           = "CWAgent"
  period              = 300
  statistic           = "Average"
  threshold           = 80  # Set threshold based on your requirements
  alarm_description   = "This alarm triggers if disk utilization exceeds 80%."
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.secondary_asg.name
  }
  actions_enabled     = true
  alarm_actions       = [aws_sns_topic.west_alert_topic.arn]  
}

# SNS Topic for Alarm Notifications in us-west-2

resource "aws_sns_topic" "west_alert_topic" {
  provider = aws.west
  name     = "WestEC2AlertTopic"
}

resource "aws_sns_topic_subscription" "west_email_subscription" {
  provider = aws.west
  topic_arn = aws_sns_topic.west_alert_topic.arn
  protocol  = "email"
  endpoint  = var.notification_email
}