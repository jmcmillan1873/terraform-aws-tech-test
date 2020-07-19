## Define remote back end for version control of state file. 
terraform {
  backend "s3" {
    region         = "eu-west-1"
    bucket         = "johnmcmillanecstechtest"
    key            = "JohnMcMillan-us-east-1.terraform.tfstate"
    encrypt        = true
    dynamodb_table = "tf-state-locking"
  }
}


## I found that despite setting aws provider in the blueprint (which works in 0.11) and defining the region above, 
## terraform was prompting for region on plan & apply. The below is a workaround. 
provider "aws" {
  region = "us-east-1"
}


## Main module below to configure the blueprint
module "environment" {
  source           = "../../blueprints/techtest"	# Location of main tf conifg
  vpc-name         = "JohnMcMillan VPC"  
  region           = "us-east-1"        		# Region to deploy to
  vpc-cidr         = "10.10.20.0/24"
  key-name         = "JohnMcMillan-us"

# Autoscaling vars:
  min-web-asg-size = 4		# Minimum webserver instance to launch in ASG
  max-web-asg-size = 8		# Maximum webserver instance to launch in ASG

# VPC Subnet vars: 
#  - a-z corresponds to the AZ name (e.g. eu-west-1a) 
#  - 0-9 corresponds to the netnum (referenced by the cidrsubnet function)
  public_subnet_numbers = {
    "a" = 0
    "b" = 1
    "c" = 2
    "d" = 3
    "e" = 4
    "f" = 5
  }

  private_subnet_numbers = {
    "a" = 8
    "b" = 9
    "c" = 10
    "d" = 11
    "e" = 12
    "f" = 13
  }
}
