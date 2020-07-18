
## Define remote back end for version control of state file. 
terraform {
  backend "s3" {
    region         = "eu-west-1"
    bucket         = "TBC"
    key            = "JohnMcMillan-us-east-1.terraform.tfstate"
    encrypt        = true
    dynamodb_table = "tf-state-locking"
  }
}

## Main module below to configure the blueprint
# This section would typically contain those differences between environments
module "environment" {
  source = "../../blueprints/techtest"
  vpc_name  = "JohnMcMillan VPC"  
  region    = "us-east-1"        
  key_name  = "TBC"
}

