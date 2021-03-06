# creating launch configuration
resource "aws_launch_configuration" "default" {
  image_id               = lookup(var.ec2_amis, var.aws_region)
  instance_type          = "t2.micro"
  security_groups        = [aws_security_group.webserver_default_ec2_security_group.id]
  user_data              = file("user_data.sh")
  lifecycle {
    create_before_destroy = true
  }
}

# creating auto-scaling group
resource "aws_autoscaling_group" "default" {
  name                        = "docker-default-autoscaling-group"
  launch_configuration = aws_launch_configuration.default.id
  #count                   = length(var.azs)
  #availability_zones       = element(var.azs,count.index)

  #vpc_zone_identifier = element(aws_subnet.private.*.id, count.index)]
  #load_balancers = aws_alb.docker_default_alb.name]

  #availability_zones       = "[${var.azs.*}]"
  vpc_zone_identifier       = aws_subnet.private.*.id

  desired_capacity = 3
  max_size = 6
  min_size = 1

  health_check_type = "ELB"
  tag {
    key = "Name"
    value = "webserver-default-asg"
    propagate_at_launch = true
  }
}

# ALB DNS is generated dynamically, return URL so that it can be used
output "url" {
  value = "http://${aws_alb.webserver_default_alb.dns_name}/"
}
