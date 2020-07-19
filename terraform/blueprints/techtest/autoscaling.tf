#-------------------------------------------
# Define Launch Configuration
#-------------------------------------------

resource "aws_launch_configuration" "web_asg_lc" {
  name_prefix     = "web_config-"
  image_id        = var.web-ami[var.region]
  instance_type   = "t3.small"
  key_name        = var.key-name
  security_groups = [aws_security_group.web-elb.id]
  user_data       = <<EOF
#!/bin/sh
yum install -y nginx
service nginx start
EOF
  lifecycle {
    create_before_destroy = true
  }
}


#------------------------------------------------
# Define necessary data
#------------------------------------------------
data "aws_availability_zones" "all" {}

data "aws_subnet" "private" {
  for_each = data.aws_subnet_ids.private.ids
  id       = each.value
}

#-------------------------------------------
# Define AutoScale Group
#-------------------------------------------

resource "aws_autoscaling_group" "web_asg" {
  name                 = "web_asg"
  launch_configuration = aws_launch_configuration.web_asg_lc.id
#  availability_zones   = data.aws_availability_zones.all.names
  vpc_zone_identifier = [ for s in data.aws_subnet.private : s.id ]
#  target_group_arns = [ aws_lb_target_group.Web_tg_80.arn, aws_lb_target_group.Web_tg_443.arn ]
  target_group_arns = [ aws_lb_target_group.Web_tg_443.arn ]
  min_size = 2
  max_size = 6 
}
