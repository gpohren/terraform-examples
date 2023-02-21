provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

# Thanks to https://churrops.io/2018/06/03/terraform-provisionamento-de-auto-scaling-groups-e-elastic-load-balancers-na-aws/

resource "aws_launch_configuration" "webserver" {
  image_id        = var.ami
  instance_type   = var.instance_micro
  security_groups = [aws_security_group.web_sg.id]
  key_name        = aws_key_pair.aws_key.key_name
  user_data       = file("user-data/web.sh")

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "scalegroup" {
  launch_configuration = aws_launch_configuration.webserver.name
  vpc_zone_identifier  = [aws_subnet.public_1a.id, aws_subnet.public_1b.id]
  min_size             = 1
  max_size             = 4
  enabled_metrics      = ["GroupMinSize", "GroupMaxSize", "GroupDesiredCapacity", "GroupInServiceInstances", "GroupTotalInstances"]
  metrics_granularity  = "1Minute"
  load_balancers       = [aws_elb.elb1.id]
  health_check_type    = "ELB"
  tag {
    key                 = "Name"
    value               = "webserver"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "autopolicy" {
  name                   = "asg-autoplicy"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.scalegroup.name
}

resource "aws_cloudwatch_metric_alarm" "cpualarm" {
  alarm_name          = "cpu-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "60"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.scalegroup.name
  }

  alarm_description = "This metric monitor EC2 instance cpu utilization"
  alarm_actions     = [aws_autoscaling_policy.autopolicy.arn]
}

resource "aws_autoscaling_policy" "autopolicy-down" {
  name                   = "asg-autoplicy-down"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.scalegroup.name
}

resource "aws_cloudwatch_metric_alarm" "cpualarm-down" {
  alarm_name          = "cpu-alarm-down"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "10"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.scalegroup.name
  }

  alarm_description = "This metric monitor EC2 instance cpu utilization"
  alarm_actions     = [aws_autoscaling_policy.autopolicy-down.arn]
}

resource "aws_elb" "elb1" {
  name            = "web-elb"
  security_groups = [aws_security_group.elb_sg.id]
  subnets         = [aws_subnet.public_1a.id, aws_subnet.public_1b.id]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 30
  }

  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags = {
    Name = "web-elb"
  }
}

resource "aws_lb_cookie_stickiness_policy" "cookie_stickness" {
  name                     = "cookiestickness"
  load_balancer            = aws_elb.elb1.id
  lb_port                  = 80
  cookie_expiration_period = 600
}