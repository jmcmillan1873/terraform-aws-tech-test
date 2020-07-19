variable "region" {
  default     = "eu-west-1"
  description = "e.g. eu-west-1"
}

variable "vpc-cidr" {
  default     = "10.10.10.0/24"
  description = "e.g. 10.10.10.0/24"
}

variable "subnet-numbers" {
  default     = [1, 2, 3]
}

# for the purpose of this exercise use the default key pair on your local system
variable "public_key" {
  default = "~/.ssh/id_rsa.pub"
}


variable "project-tag" {
  default = "Tech Test"
}

variable "owner-tag" {
  default = "JohnMcMillan"
}

variable "vpc-name" {
  default = "JohnMcMillan-Test-VPC"
}

variable "public_subnet_numbers" {
  default     = {
    "a" = 0
    "b" = 1
    "c" = 2
  }
}

variable "private_subnet_numbers" {
  default     = {
    "a" = 4
    "b" = 5
    "c" = 6
  }
}

variable "web-ami" {
  type = map
  default = {
    eu-west-1 = "ami-047bb4163c506cd98"
    us-east-1 = "ami-0ff8a91507f77f867"
  }
}

variable "key-name" {
}
