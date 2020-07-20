#-------------------------------------------
# Setup Dynamodb Table for recording status
# of deployed instances
#-------------------------------------------

resource "aws_dynamodb_table" "ec2reports-table" {
   name           = "ec2reports"
   billing_mode   = "PROVISIONED"
   read_capacity  = "5"
   write_capacity = "5"
   hash_key       = "ttl"
   range_key      = "date"

   attribute {
      name = "ttl"
      type = "N"
   }

   attribute {
      name = "date"
      type = "S"
   }
   attribute {
      name = "message"
      type = "S"
   }

# Use TTL to expire items after 24 hours
   ttl {
      attribute_name = "ttl"
      enabled        = true
   }


   global_secondary_index {
      name            = "message-index"
      hash_key        = "message"
      read_capacity   = "5"
      write_capacity  = "5"
      projection_type = "KEYS_ONLY"
  }

  tags = {
    Project = var.project-tag
    Owner = var.owner-tag
  }

}
