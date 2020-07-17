#!/bin/sh

# Run a couple of commands that should be first time setup only. 
# This is my approach to dealing with the chicken/Egg situation between terraform being aware of/managing resources to hold statefile and locking details. 

# Create an S3 bucket to hold the terraform state file
# This bucket has
#  - encryption at rest enabled by default
#  - versioning enabled, to preserve previous versions of tfstate
#  - lifecycle policy to archive old state file to glacier after 30 days, then delete after 90 days
#  - restrictive but functional permissions - meaning private, not public. Accessible to local IAM users with S3 permissions.

BUCKETNAME=johnmcmillanecstechtest
aws s3 mb s3://$BUCKETNAME
aws s3api put-bucket-encryption --bucket $BUCKETNAME --server-side-encryption-configuration file://encryption.json
aws s3api put-bucket-versioning --bucket $BUCKETNAME --versioning-configuration Status=Enabled
aws s3api put-bucket-lifecycle-configuration --bucket $BUCKETNAME --lifecycle-configuration file://lifecycle.json
aws s3api put-bucket-acl --acl private --bucket $BUCKETNAME
aws s3api put-public-access-block --bucket $BUCKETNAME --public-access-block-configuration "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"



# Create the DynamoDB table to hold a lock on the statefile to prevent corruption
aws dynamodb create-table --region eu-west-1 --table-name tf-state-locking --attribute-definitions AttributeName=LockID,AttributeType=S --key-schema AttributeName=LockID,KeyType=HASH --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 
