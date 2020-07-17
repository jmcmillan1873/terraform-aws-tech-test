#!/bin/sh

# Create an S3 bucket to hold the terraform state file
# This bucket has
#  - encryption at rest enabled by default
#  - versioning enabled, to preserve previous versions of tfstate
#  - lifecycle policy to archive old state file to glacier after 30 days, then delete after 90 days
#  - default permissions - meaning private, not public. Accessible to local IAM users with S3 permissions. 

aws s3 mb s3://JohnMcMillanECSTechTest
aws s3api put-bucket-encryption --bucket JohnMcMillanECSTechTest --server-side-encryption-configuration '{  "Rules": [
    {
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "AES256"
      }
    }
  ]
}'


aws s3api put-bucket-versioning --bucket JohnMcMillanECSTechTest --versioning-configuration Status=Enabled
aws s3api put-bucket-lifecycle-configuration --bucket JohnMcMillanECSTechTest --lifecycle-configuration file://lifecycle.json


