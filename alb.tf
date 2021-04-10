# security group for application load balancer
resource "aws_security_group" "webserver_default_alb_sg" {
  name        = "webserver-nginx-default-alb-sg"
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
    Name = "alb-security-group-webserver-nginx-default"
  }
}

# using ALB - instances in private subnets
resource "aws_alb" "webserver_default_alb" {
  name                      = "webserver-default-alb"
  security_groups           = [aws_security_group.webserver_default_alb_sg.vpc_id]
  subnets                   = aws_subnet.public.*.vpc_id
  tags = {
    Name = "webserver-default-alb"
  }
}

# alb target group
resource "aws_alb_target_group" "webserver-default-tg" {
  name     = "webserver-alb-target-group"
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
  load_balancer_arn = aws_alb.webserver_default_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.webserver-default-tg.arn
    type             = "forward"
  }
}

# target group attach
# using nested interpolation functions and the count parameter to the "aws_alb_target_group_attachment"
resource "aws_lb_target_group_attachment" "webserver-default" {
  count            = length(var.azs)
  target_group_arn = aws_alb_target_group.webserver-default-tg.arn
  target_id        = element(split(",", join(",", aws_instance.webserver_default.*.id)), count.index)
  port             = 80
}
