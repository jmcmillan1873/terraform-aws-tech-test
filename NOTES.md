# JohnMcMillan - ECS test attempt

I've attempted to complete the solution using a terraform approach I've been used to: blueprints + environments.  

* "blueprints" being re-useable collections of terraform resources to make up an entire solution, e.g. a lamp stack, or an nginx autoscale group
* "environments" being configurable / launchable references to blueprints.

The blueprint ensures the stack is consistent where it needs to be (e.g. network structure), while the environments allow for configuring necessary differences (e.g. different vpc cidr) 

The layout is as follows:

```
├ JohnMcMillan-Attempt
│  └ terraform
│     └ blueprints
│        └ techtest
│           ├ elbs.tf
│           ├ main.tf
│           ├ security_groups.tf
│           ├ variables.tf
│           └ vpc.tf
│     └ environments
│        └ eu-west-1
│           └ web.tf
│        └ us-east-1
│           └ web.tf
```



You'll notice I've split main.tf into component parts, e.g. instances.tf vpc.tf, etc
This is partly for simpler, smaller, more readable files. 
However I find that when looking at git history you can see at a high level what's been changed (e.g. "git log --name-only" would show that loadbalancers.tf, or rds.tf had been changed, rather main.tf)
