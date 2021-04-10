# security group for application load balancer
resource "aws_security_group" "docker_default_alb_sg" {
  name        = "docker-nginx-default-alb-sg"
  description = "allow incoming HTTP traffic only"
  vpc_id      = local.vpc_id

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "alb-security-group-docker-default"
  }
}

# using ALB - instances in private subnets
resource "aws_alb" "docker_default_alb" {
  name                      = "docker-default-alb"
  security_groups           = [aws_security_group.docker_default_alb_sg.id]
  subnets                   = aws_subnet.public.*.id
  tags = {
    Name = "docker-default-alb"
  }
}

# alb target group
resource "aws_alb_target_group" "docker-default-tg" {
  name     = "docker-default-alb-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = local.vpc_id
  health_check {
    path = "/"
    port = 80
  }
}

# listener
resource "aws_alb_listener" "http_listener" {
  load_balancer_arn = aws_alb.docker_default_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.docker-default-tg.arn
    type             = "forward"
  }
}

# target group attach
# using nested interpolation functions and the count parameter to the "aws_alb_target_group_attachment"
resource "aws_lb_target_group_attachment" "docker-default" {
  count            = length(var.azs)
  target_group_arn = aws_alb_target_group.docker-default-tg.arn
  target_id        = element(split(",", join(",", aws_instance.docker_default.*.id)), count.index)
  port             = 80
}
