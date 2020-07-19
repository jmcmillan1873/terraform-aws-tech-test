data "aws_subnet_ids" "public" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Tier = "Public"
  }
}

data "aws_subnet_ids" "private" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Tier = "Private"
  }
}

data "aws_subnet" "public" {
  for_each = data.aws_subnet_ids.public.ids
  id       = each.value
}

output "public_subnets" {
  value = [ for s in data.aws_subnet.public : s.id]
}
