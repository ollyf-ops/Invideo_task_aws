# AutoScaling Policy
# Here, we specified increasing instance by 1 (scaling_adjustment = “1”)
# period without scaling (5 minutes-cooldown)
# policy type, Simple scaling—Increase or decrease the current capacity of the group 
# based on a single scaling adjustment.
# Then we creates cloudwatch alarm wich triggers autoscaling policy which will compare CPU utilization.
# If average of CPU utilization is higher than 60% for 2 consecutive periods (120*2 sec),
# then a new instance will be created.
# If average of CPU utilization is lower than 50% for 2 consecutive periods (120*2 sec),
# then a new instance will be created.


# scale up alarm
resource "aws_autoscaling_policy" "default-cpu-policy" {
	name = "default-cpu-policy"
	autoscaling_group_name = aws_autoscaling_group.default.name
	adjustment_type = "ChangeInCapacity"
	scaling_adjustment = "1"
	cooldown = "300"
	policy_type = "SimpleScaling"
}

resource "aws_cloudwatch_metric_alarm" "default-cpu-alarm" {
	alarm_name = "default-cpu-alarm"
	alarm_description = "default-cpu-alarm"
	comparison_operator = "GreaterThanOrEqualToThreshold"
	evaluation_periods = "2"
	metric_name = "CPUUtilization"
	namespace = "AWS/EC2"
	period = "120"
	statistic = "Average"
	threshold = "60"   
	dimensions = {
		"AutoScalingGroupName" = aws_autoscaling_group.default.name
	}
	actions_enabled = true
	alarm_actions = [aws_autoscaling_policy.default-cpu-policy.arn]
}


# scale down alarm
resource "aws_autoscaling_policy" "default-cpu-policy-scaledown" {
	name = "default-cpu-policy-scaledown"
	autoscaling_group_name = aws_autoscaling_group.default.name
	adjustment_type = "ChangeInCapacity"
	scaling_adjustment = "-1"
	cooldown = "300"
	policy_type = "SimpleScaling"
}

resource "aws_cloudwatch_metric_alarm" "default-cpu-alarm-scaledown" {
	alarm_name = "default-cpu-alarm-scaledown"
	alarm_description = "default-cpu-alarm-scaledown"
	comparison_operator = "LessThanOrEqualToThreshold"
	evaluation_periods = "2"
	metric_name = "CPUUtilization"
	namespace = "AWS/EC2"
	period = "120"
	statistic = "Average"
	threshold = "50"
	dimensions = {
		"AutoScalingGroupName" = aws_autoscaling_group.default.name
	}
	actions_enabled = true
	alarm_actions = [aws_autoscaling_policy.default-cpu-policy-scaledown.arn]
}