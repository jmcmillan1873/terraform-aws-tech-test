#-------------------------------------------
# Define Launch Configuration for web
#-------------------------------------------

resource "aws_launch_configuration" "web_asg_lc" {
  name_prefix     = "web_config-"
  image_id        = var.web-ami[var.region]
  instance_type   = "t3.small"
  key_name        = var.key-name
  security_groups = [aws_security_group.web.id]
  user_data       = <<EOF
#!/bin/sh
yum install -y nginx
service nginx start
EOF
  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Description      = "Launch Config for Web ASG"
    Owner            = var.owner-tag
    Project          = var.project-tag
  }
}


#-------------------------------------------
# Define Web AutoScale Group
#-------------------------------------------

resource "aws_autoscaling_group" "web_asg" {
  name                 = "web_asg"
  launch_configuration = aws_launch_configuration.web_asg_lc.id
  vpc_zone_identifier  = [ for s in data.aws_subnet.private : s.id ]
  target_group_arns    = [ aws_lb_target_group.Web_tg_443.arn ]
  min_size             = var.min-web-asg-size
  max_size             = var.max-web-asg-size 
  
  tags = {
    Description      = "Web ASG member"
    Name             = "WebASGNginx"
    Owner            = var.owner-tag
    Project          = var.project-tag
  }
}


#-------------------------------------------
# Define Launch Configuration for Bastion
#-------------------------------------------

resource "aws_launch_configuration" "bastion_lc" {
  name_prefix     = "bastion_config-"
  image_id        = var.web-ami[var.region]
  instance_type   = "t3.small"
  key_name        = var.key-name
  security_groups = [aws_security_group.bastion.id]
  associate_public_ip_address = true
  lifecycle {
    create_before_destroy = true
  }
  tags = {
    Description      = "Launch Config for Bastion ASG"
    Owner            = var.owner-tag
    Project          = var.project-tag
  }
}

#-------------------------------------------
# Define Bastion AutoScale Group
#-------------------------------------------

resource "aws_autoscaling_group" "bastion_asg" {
  name                 = "bastion_asg"
  launch_configuration = aws_launch_configuration.bastion_lc.id
  vpc_zone_identifier = [ for s in data.aws_subnet.public : s.id ]
  min_size = 1
  max_size = 1 

  tags = {
    Description      = "Bastion providing SSH access to vpc"
    Name             = "Bastion"
    Owner            = var.owner-tag
    Project          = var.project-tag
  }
}
