#-------------------------------------------
# Deploy lambda function to record ec2 status
#-------------------------------------------

resource "aws_lambda_function" "ec2reports_lambda" {
   function_name = "ec2reports"
   s3_bucket     = "johnmcmillanecstechtest"
   s3_key        = "ec2reports-function.py.zip"
   role          = "arn:aws:iam::680558138144:role/service-role/ec2report-to-lambda"
   handler       = "ec2reports-function.lambda_handler"
   timeout       = "20"
   runtime = "python3.7"
}
