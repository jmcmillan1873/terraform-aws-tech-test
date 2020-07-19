variable "region" {
  default     = "eu-west-1"
  description = "e.g. eu-west-1"
}

variable "vpc-cidr" {
  default     = "10.10.10.0/24"
  description = "e.g. 10.10.10.0/24"
}

# for the purpose of this exercise use the default key pair on your local system
variable "public_key" {
  default     = "~/.ssh/id_rsa.pub"
}


variable "project-tag" {
  default     = "Tech Test"
}

variable "owner-tag" {
  default     = "JohnMcMillan"
}

variable "vpc-name" {
  default     = "JohnMcMillan-Test-VPC"
}

variable "public_subnet_numbers" {
  default     = {
    "a" = 0
    "b" = 1
    "c" = 2
  }
}

variable "private_subnet_numbers" {
  type        = map
  default     = {
    "a" = 4
    "b" = 5
    "c" = 6
  }
}

variable "web-ami" {
  type        = map
  default = {
    eu-west-1 = "ami-047bb4163c506cd98"
    us-east-1 = "ami-0ff8a91507f77f867"
  }
}

variable "key-name" {
  default     = "JohnMcMillan"
}

variable "ssl-arn" {
  type        = map
  default     = {
    eu-west-1 = "arn:aws:acm:eu-west-1:680558138144:certificate/47b45599-f14e-4345-ab3a-2271fdaa849e"
    us-east-1 = "arn:aws:acm:us-east-1:680558138144:certificate/bb5c74f0-aba8-4f73-a112-deeb9bb2af27"
  }
}

variable "min-web-asg-size" {
  default     = "2"
}

variable "max-web-asg-size" {
  default     = "6"
}
