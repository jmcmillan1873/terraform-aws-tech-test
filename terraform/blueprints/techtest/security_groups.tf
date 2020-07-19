#-------------------------------------------
# Web EC2 Security Group
#-------------------------------------------

resource "aws_security_group" "web" {
  name        = "Web EC2 Tier"
  description = "Web Tier Security Group for EC2"
  vpc_id      = aws_vpc.vpc.id

  # SSH Access from bastion
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }

  # http/https access from ELB
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.web-elb.id]
  }

  # OUTBOUND
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


#-------------------------------------------
# Bastion EC2 Security Group
#-------------------------------------------

resource "aws_security_group" "bastion" {
  name        = "Bastion EC2 Tier"
  description = "Bastion Security Group for EC2"
  vpc_id      = aws_vpc.vpc.id

  # SSH Access from world
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # OUTBOUND

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc-cidr]
  }
}


#-------------------------------------------
# Web ELB Security Group
#-------------------------------------------

resource "aws_security_group" "web-elb" {
  name        = "Web ELB Tier"
  description = "Web Security Group for ELB"
  vpc_id      = aws_vpc.vpc.id

  # http/https Access from world
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # OUTBOUND

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.vpc-cidr]
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc-cidr]
  }
}
