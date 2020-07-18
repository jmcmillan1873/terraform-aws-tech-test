#-------------------------------------------
# Define the VPC
#-------------------------------------------

resource "aws_vpc" "vpc" {
  lifecycle {
    prevent_destroy = "false"
  }
  cidr_block           = var.vpc-cidr
  enable_dns_hostnames = true
  tags = {
    Project = var.project-tag
    Owner = var.owner-tag
    Name = var.vpc-name
  }
}


#-------------------------------------------
# Setup Internet Gateway
#-------------------------------------------
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Project = var.project-tag
    Owner = var.owner-tag
  }
}


#-------------------------------------------
# Setup Nat Gateway
#-------------------------------------------

resource "aws_eip" "nat1" {
  vpc = true
}

resource "aws_nat_gateway" "gw1" {
  allocation_id = aws_eip.nat1.id
  subnet_id     = aws_subnet.public["a"].id
  tags = {
    Project = var.project-tag
    Owner = var.owner-tag
  }
}


#-------------------------------------------
# Setup Public Subnets + route table
#-------------------------------------------

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

resource "aws_subnet" "public" {
  for_each = var.public_subnet_numbers
  lifecycle {
    prevent_destroy = "false"
  }
  vpc_id            = aws_vpc.vpc.id
  availability_zone = "${var.region}${each.key}"
  cidr_block        = cidrsubnet(var.cidr, 3, each.value)
  tags = {
    Name = "Public Subnet ${each.key}"
  }
}

resource "aws_route_table_association" "public" {
  for_each       = var.public_subnet_numbers
  subnet_id      = aws_subnet.public["${each.key}"].id
  route_table_id = aws_route_table.public_route_table.id
}



#-------------------------------------------
# Setup Private Subnets + route table
#-------------------------------------------

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.gw1.id
  }
}

resource "aws_subnet" "private" {
  for_each = var.private_subnet_numbers
  lifecycle {
    prevent_destroy = "false"
  }
  vpc_id            = aws_vpc.vpc.id
  availability_zone = "${var.region}${each.key}"
  cidr_block        = cidrsubnet(var.cidr, 3, each.value )
  tags = {
    Name = "Private Subnet ${each.key}"
  }
}

resource "aws_route_table_association" "private" {
  for_each       = var.private_subnet_numbers
  subnet_id      = aws_subnet.private["${each.key}"].id
  route_table_id = aws_route_table.private_route_table.id
}

