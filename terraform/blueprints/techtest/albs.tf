#------------------------------------------------
# Define necessary data
#------------------------------------------------
#data "aws_subnet" "public" {
#  for_each = data.aws_subnet_ids.public.ids
#  id       = each.value
#}

#------------------------------------------------
# Web ALB
#------------------------------------------------

resource "aws_lb" "Web-ALB" {
  name               = "techtest-web-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = [ for s in data.aws_subnet.public : s.id ]
  security_groups    = [aws_security_group.web-elb.id]

  enable_deletion_protection = true

  tags = {
    Description      = "Web ALB"
    Owner            = var.owner-tag
    Project          = var.project-tag
  }
}


#------------------------------------------------
# Define ALB listners
#------------------------------------------------
#Internal ALB Listener 80 - Redirect http requests to https
resource "aws_lb_listener" "Web-ALB-http-listener" {
  load_balancer_arn = aws_lb.Web-ALB.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type            = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  tags = {
    Description     = "Web ALB http listener"
    Owner           = var.owner-tag
    Project         = var.project-tag
  }
}

#Internal ALB Listener 443
resource "aws_lb_listener" "Web-ALB-https-listener" {
  load_balancer_arn = aws_lb.Web-ALB.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.ssl-arn[var.region]

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.Web_tg_443.arn
  }

  tags = {
    Description      = "Web ALB https listener"
    Owner            = var.owner-tag
    Project          = var.project-tag
  }
}



#------------------------------------------------
# Target groups for the ALB
#------------------------------------------------
resource "aws_lb_target_group" "Web_tg_443" {
  name            = "TechTest-Web-tg-https"
# Deliberately listing on port 80 - i.e. doing SSL termination on the ALB only for purposes of test
  port            = "80"
  protocol        = "HTTP"
  vpc_id          = aws_vpc.vpc.id

  health_check {
    path     = "/"
    matcher  = "200"
    protocol = "HTTPS"
  }

  tags = {
    Description      = "Web ALB https target group"
    Owner            = var.owner-tag
    Project          = var.project-tag
  }
}


#------------------------------------------------
# Output DNS name of ALB
#------------------------------------------------

output "elb-dns" {
  value = aws_lb.Web-ALB.dns_name
}
