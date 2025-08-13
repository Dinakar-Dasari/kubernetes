module "ingress_alb" {
  source = "terraform-aws-modules/alb/aws"
  version = "9.16.0"
  internal = false
  name    = "${var.project}-${var.environment}-ingress-alb" #roboshop-dev-backend-alb
  vpc_id  = aws_vpc.main.id
  subnets = aws_subnet.public[*].id
  create_security_group = false
  security_groups = [aws_security_group.ingress.id]
  enable_deletion_protection = false
  tags = merge(
    {
        Name = "${var.project}-${var.environment}-ingress-alb"
    }
  )
}

resource "aws_lb_listener" "ingress_alb" {
  load_balancer_arn = module.ingress_alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.cert.arn
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/html"
      message_body = "<h1>Hello, I am from ingress ALB using HTTPS</h1>"
      status_code  = "200"
    }
  }
}

resource "aws_route53_record" "ingress_alb" {
  zone_id = var.aws_zone_id
  name    = "${var.environment}.${var.aws_zone_name}"
  type    = "A"

  alias {
    name                   = module.ingress_alb.dns_name
    zone_id                = module.ingress_alb.zone_id # This is the ZONE ID of ALB
    evaluate_target_health = true
  }
}
