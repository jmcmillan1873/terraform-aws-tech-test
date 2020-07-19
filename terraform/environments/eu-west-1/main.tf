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
  source = "../../blueprints/techtest"
  vpc-name  = "JohnMcMillan VPC"  
  region    = "eu-west-1"        
  key-name  = "JohnMcMillan"
}
