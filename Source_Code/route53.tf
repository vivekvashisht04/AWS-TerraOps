# Route 53 Hosted Zone

resource "aws_route53_zone" "main" {
  name = var.route53_zone_domain
  
  # Associate with the VPC in us-east-1
  vpc {
    vpc_id = aws_vpc.main_vpc.id  # us-east-1 VPC
  }

  # Associate with the VPC in us-west-2
  vpc {
    vpc_id = aws_vpc.west_vpc.id  # us-west-2 VPC
    vpc_region = "us-west-2"
  }
}


# Primary Route 53 Record (us-east-1)

resource "aws_route53_record" "primary" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "app.${var.route53_zone_domain}"
  type    = "A"

  alias {
    name                   = aws_lb.primary_alb.dns_name
    zone_id                = aws_lb.primary_alb.zone_id
    evaluate_target_health = true
  }

  set_identifier = "Primary"
  failover_routing_policy {
    type = "PRIMARY"
  }
}

# Secondary Route 53 Record (us-west-2)

resource "aws_route53_record" "secondary" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "app.${var.route53_zone_domain}"
  type    = "A"

  alias {
    name                   = aws_lb.secondary_alb.dns_name
    zone_id                = aws_lb.secondary_alb.zone_id
    evaluate_target_health = true
  }

  set_identifier = "Secondary"
  failover_routing_policy {
    type = "SECONDARY"
  }
}

# Route 53 Health Checks

# Primary Health Check (us-east-1)

resource "aws_route53_health_check" "primary_health_check" {
  fqdn             = aws_lb.primary_alb.dns_name  # Use ALB DNS Name 
  type             = "HTTP"
  port             = 80
  request_interval = 30
  failure_threshold = 3
}

# Secondary Health Check (us-west-2)

resource "aws_route53_health_check" "secondary_health_check" {
  fqdn             = aws_lb.secondary_alb.dns_name  # Use ALB DNS Name 
  type             = "HTTP"
  port             = 80
  request_interval = 30
  failure_threshold = 3
}