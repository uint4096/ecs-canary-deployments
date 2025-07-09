
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_security_group" "alb" {
  name_prefix = "alb-sg"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb_target_group" "prod-tg" {
  name        = "prod-tg"
  port        = 8080
  target_type = "ip"
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.default.id
  
  health_check {
    enabled           = true
    healthy_threshold = 2
    path              = "/"
    matcher           = "200"
  }
}

resource "aws_lb_target_group" "canary-tg" {
  name        = "canary-tg"
  port        = 8080
  target_type = "ip"
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.default.id
  
  health_check {
    enabled           = true
    healthy_threshold = 2
    path              = "/"
    matcher           = "200"
  }
}

resource "aws_lb" "minimal-lb" {
  name               = "minimal-lb"
  load_balancer_type = "application"
  internal           = false
  security_groups    = [aws_security_group.alb.id]
  subnets            = data.aws_subnets.default.ids
}

resource "aws_lb_listener" "minimal-lb-listener" {
  load_balancer_arn = aws_lb.minimal-lb.arn
  port = 80
  protocol = "HTTP"

  default_action {
    type = "forward"
    forward {
      target_group {
        arn    = aws_lb_target_group.prod-tg.arn
        weight = 90
      }
      target_group {
        arn    = aws_lb_target_group.canary-tg.arn
        weight = 10
      }
    }
  }
}
