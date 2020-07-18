#-------------------------------------------
# Define Launch Configuration
#-------------------------------------------

resource "aws_launch_configuration" "web_asg_lc" {
  name_prefix     = "web_config-"
  image_id        = var.web-ami[var.region]
  instance_type   = t3.small
  key_name        = [TBC]
  security_groups = [TBC]
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
#data "aws_availability_zones" "all" {}

#data "aws_availability_zones" "example" {
#  all_availability_zones = true
#}

resource "aws_autoscaling_group" "web_asg" {
  name                 = "web_asg"
  launch_configuration = aws_launch_configuration.web_asg_lc.id
  availability_zones   = data.aws_availability_zones.all.names
  min_size = 2
  max_size = 6 
}
