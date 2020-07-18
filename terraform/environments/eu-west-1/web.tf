## Setup dynamodb table for state locking
resource "aws_dynamodb_table" "tf-state-locking" {
  name           = "tf-state-locking"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}

## Define remote back end for version control of state file. 
terraform {
  backend "s3" {
    region         = "eu-west-1"
    bucket         = "TBC"
    key            = "JohnMcMillan-eu-west-1.terraform.tfstate"
    encrypt        = true
    dynamodb_table = "tf-state-locking"
  }
}

## Main module below to configure the blueprint
# This section would typically contain those differences between environments
module "environment" {
  source = "../../blueprints/techtest"
  vpc_name  = "JohnMcMillan VPC"  
  region    = "eu-west-1"        
  key_name  = "TBC"
}

