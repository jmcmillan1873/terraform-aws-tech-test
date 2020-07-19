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


#-------------------------------------------
# Define AutoScale Group
#-------------------------------------------
data "aws_availability_zones" "all" {}

data "aws_subnet" "private" {
  for_each = data.aws_subnet_ids.private.ids
  id       = each.value
}

resource "aws_autoscaling_group" "web_asg" {
  name                 = "web_asg"
  launch_configuration = aws_launch_configuration.web_asg_lc.id
  availability_zones   = data.aws_availability_zones.all.names
  vpc_zone_identifier = [ for s in data.aws_subnet.private : s.id ]
  min_size = 2
  max_size = 6 
}
