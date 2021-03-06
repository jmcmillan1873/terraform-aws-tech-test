# JohnMcMillan - ECS test attempt

# Quickstart
To jump straight into deploying:&nbsp;
note: before starting these steps you'll need to configure your environment with suitable credentials, e.g. 'aws configure' to deploy access keys
```
cd terraform/environments/(eu-west-1 | us-east-1)
terraform init
terraform apply -target module.environment.aws_route_table_association.public
terraform apply -target module.environment.aws_route_table_association.private
terraform apply
```

# Summary of my proposed solutions
1) To improve resilience, I've replaced the statically defined Web EC2 instance with Autoscaling group. (blueprints/techtest/autoscaling.tf)
   In terms of best practice I've moved the EC2 instance to the private subnet, they're still accessible from the internet via the ALB which *is* in the public subnet.  (blueprints/techtest/vpc.tf)
   Using the autoscale group meant that I needed to create a loadbalancer, defined in blueprints/techtest/albs.tf.
   I've also added a dummy cert to allow SSL termination on the ALB rather than opting for http. The http listener on the ALB redirects to https (I imported the cert to ACM but didn't use Terraform for this.)
   
2) I've written the blueprint in such a way that it can accomodate regions of a different size, e.g. the 3 AZ's in eu-west-1 or the 6 AZ's in us-east-1. (blueprints/techtest/vpc.tf)
   it does this by using map variablies (public_subnet_numbers & private_subnet_numbers) which allows us to link AZ's (e.g. 'a' for AzA) to the [netnum](https://www.terraform.io/docs/configuration/functions/cidrsubnet.html) we want to use within the cidr. 
   data.tf defines datasets that allow for easier interpolation of the subnet ids when defing other resources, e.g. the alb..

3) Bastion server added, again as an autoscale group, this time with a max count of 1 for basic fault tolerance & auto recovery.(blueprints/techtest/autoscaling.tf)
   Security groups have been configuired to only permit SSH access to the web tier from the bastion. (blueprints/techtest/security_groups.tf)

4) Basic lambda function, using the python3.7 runtime, deployed and publishing results to dynamodb.
   blueprints/techtest/lambda.tf uploads the python script (blueprints/techtest/ec2reports-function.py.zip), sets up the function and configures the trigger to run it every hour
   The lambda function queires the ec2 instances and writes their current status along with a ttl in epoch time, & and a human readable date/time stamp.
   blueprints/techtest/dynamodb.tf creates the table for the the lambda function to write to. 
   I've used the TTL feature in Dynamodb to ensure that items are cleared out after 24 hours - it looks at the ttl attribute on each item to do this.


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
│        ├ dynamodb.tf
│        ├ ec2reports-function.py.zip
│        ├ lambda.tf
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
  - terraform 0.12.28 + aws provider 2.70
  - aws cli 1.18.38

* SSL certs:
With a thought to 'best practice' I've setup the ALB for SSL termination, using a dummy cert I've created. I've uploaded the cert to AWS ACM and use a map variable to refer to the ALB to the correct cert arn. 


# Rationale for using "-target" on the first round of applies:
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
* I've struggled to have the code output the dns_name of the Application load balancer. At this stage I think I've missed something silly which is most likely, or I've run up against a bug (which is less likely). 
As a workaround you can obtain the details needed to test using:
```
cd terraform/environments/<< region >>
terraform show | grep dns_name
```

* Up until tf 0.11 I've had no issues using a variable in something like blueprints/techtest/main.tf to define the region in the provider. 
In this case that wouldn't work as documented, as such I've used a workaround - defining the provider's region in the environments main.tf (e.g. environments/eu-west-1/main.tf)

* Best practice choices: I've configured the ALB to explictly have no termination proctection - that isn't necessarily best practice but simplifies the clean up of the lab/test attempt too. 
I've also used lifecycle management on a few resources - to demo the possiblity of using "prevent_destroy" to provide additional protection to accidental deletion - again with a view to keeping clean up simple, I've left this set to 'false' where it's been used.
