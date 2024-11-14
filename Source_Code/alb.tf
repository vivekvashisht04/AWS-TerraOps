# Application Load Balancer (ALB) (us-east-1)

resource "aws_lb" "primary_alb" {
  name               = var.primary_alb_name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.app_sg.id]  # Attach the security group
  subnets            = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id] 

  enable_deletion_protection = false
  idle_timeout               = 400

  tags = {
    Name = "PrimaryALB"
  }
}

# ALB Target Group for us-east-1

resource "aws_lb_target_group" "primary" {
  name     = "primary-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main_vpc.id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "PrimaryTargetGroup"
  }
}

# ALB Listener for HTTP traffic

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.primary_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.primary.arn
  }

  tags = {
    Name = "PrimaryALBListener"
  }
}

# Application Load Balancer (ALB) for us-west-2

resource "aws_lb" "secondary_alb" {
  provider           = aws.west
  name               = var.secondary_alb_name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.west_app_sg.id]
  subnets            = [aws_subnet.west_public_subnet_1.id, aws_subnet.west_public_subnet_2.id] 

  enable_deletion_protection = false
  idle_timeout               = 400

  tags = {
    Name = "SecondaryALB"
  }
}

# ALB Target Group for us-west-2

resource "aws_lb_target_group" "secondary" {
  provider = aws.west
  name     = "secondary-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.west_vpc.id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "SecondaryTargetGroup"
  }
}

# ALB Listener for HTTP traffic in us-west-2

resource "aws_lb_listener" "secondary_http" {
  provider         = aws.west
  load_balancer_arn = aws_lb.secondary_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.secondary.arn
  }

  tags = {
    Name = "SecondaryALBListener"
  }
}