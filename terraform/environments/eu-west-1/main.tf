## Define remote back end for version control of state file. 
terraform {
  backend "s3" {
    region         = "eu-west-1"
    bucket         = "johnmcmillanecstechtest"
    key            = "JohnMcMillan-eu-west-1.terraform.tfstate"
    encrypt        = true
    dynamodb_table = "tf-state-locking"
  }
}


## I found that despite setting aws provider in the blueprint (which works in 0.11) and defining the region above, 
## terraform was prompting for region on plan & apply. The below is a workaround. 
provider "aws" {
  region = "eu-west-1"
}


## Main module below to configure the blueprint
module "environment" {
  source           = "../../blueprints/techtest"	# Location of main tf conifg
  vpc-name         = "JohnMcMillan VPC"  
  region           = "eu-west-1"        		# Region to deploy to

# Autoscaling vars:
  min-web-asg-size = 2		# Minimum webserver instance to launch in ASG
  max-web-asg-size = 6		# Maximum webserver instance to launch in ASG

# VPC Subnet vars: 
#  - a-z corresponds to the AZ name (e.g. eu-west-1a) 
#  - 0-9 corresponds to the netnum (referenced by the cidrsubnet function)
  public_subnet_numbers = {
    "a" = 0
    "b" = 1
    "c" = 2
  }

  private_subnet_numbers = {
    "a" = 4
    "b" = 5
    "c" = 6
  }
}
