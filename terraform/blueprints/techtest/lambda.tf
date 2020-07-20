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
   runtime       = "python3.7"
}


resource "aws_cloudwatch_event_rule" "ec2reports-schedule" {
   name                = "ec2reports-schedule"
   description         = "Runs the ec2reports lambda function every hour"
   schedule_expression = "cron(37 * * * ? *)"
}

resource "aws_cloudwatch_event_target" "ec2reports-target" {
   rule = aws_cloudwatch_event_rule.ec2reports-schedule.name
   arn  = aws_lambda_function.ec2reports_lambda.arn
}

resource "aws_lambda_permission" "ec2reports-caller" {
   statement_id  = "AllowExecutionFromCloudWatch"
   action        = "lambda:InvokeFunction"
   function_name = aws_lambda_function.ec2reports_lambda.function_name
   principal     = "events.amazonaws.com"
   source_arn    = aws_cloudwatch_event_rule.ec2reports-schedule.arn
}
