# JohnMcMillan - ECS test attempt

# Quickstart
To jump straight into deploying:
```
cd terraform/environments/<< region >>
terraform apply -target module.environment.aws_route_table_association.public
terraform apply -target module.environment.aws_route_table_association.private
terraform apply
```

# Overview & Context
I've attempted to complete the solution using a terraform approach I've been used to: blueprints + environments.  

* "blueprints" being re-useable collections of terraform resources to make up an entire solution, e.g. a lamp stack, or an nginx autoscale group
* "environments" being configurable / launchable references to blueprints.

The blueprint ensures the stack is consistent where it needs to be (e.g. network structure), while the environments allow for configuring necessary differences (e.g. different vpc cidr) 

The layout is as follows:

```
├ terraform
│  └ blueprints
│     └ techtest
│        ├ albs.tf
│        ├ autoscaling.tf
│        ├ data.tf
│        ├ main.tf
│        ├ security_groups.tf
│        ├ variables.tf
│        └ vpc.tf
│  └ environments
│     └ eu-west-1
│        └ main.tf
│        └ versions.tf
│     └ us-east-1
│        └ main.tf
│        └ versions.tf
```



# Useful info:
* if you'd like to SSH onto the bastion for testing the private SSH keys have been stored in AWS Secrets Manager
  - In eu-west-1 you'll find "SSH_Key_Tech_Test_JohnMcMillan"
  - In us-east-1 you'll find "SSH_Key_Tech_Test_JohnMcMillan-us"

* To simplify first time setup/terraform init I've scripted the creation of an S3 bucket and a Dynamodb table outside of terraform. 
  This avoids the chicken/egg situation of using terraform to create resources you rely on for state file management. 
  I've added this script to the repo under the "FirstTimeSetup" directory. 

* My setup:
  - terraform 0.12.28 / aws provifer 2.70
  - aws cli 1.18.38


# Rationale for using targetting route table associations first:
If you attempt to run "terraform apply" immediately after the terraform init, you'll run into an issue similar to the following:
```
Error: Invalid for_each argument

  on ../../blueprints/techtest/data.tf line 11, in data "aws_subnet" "private":
  11:   for_each = data.aws_subnet_ids.private.ids

The "for_each" value depends on resource attributes that cannot be determined
until apply, so Terraform cannot predict how many instances will be created.
To work around this, use the -target argument to first apply only the
resources that the for_each depends on.
```

Using the terraform recommended workaround, in this case by targetting the route table associations, we trigger enough of the terraform apply process to record enough data for the subsequent for_each process. 
Hence the third terraform apply shown in 'quickstart' needs no target.

# Bugs / Known issues. 
I've struggled to have the code output the dns_name of the Application load balancer. At this stage I think I've missed something silly which is most likely, or I've run up against a bug (which is less likely). 
As a workaround you can obtain the details using
```
terraform show | grep dns_name
```
