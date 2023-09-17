
resource "aws_lambda_function" "certbot" {
  function_name    = "lambda-certbot"
  runtime          = "python3.8"
  role             = aws_iam_role.x.arn
  handler          = "main.lambda_handler"
  filename         = local.lambda_filename
  source_code_hash = filebase64sha256(local.lambda_filename)
  description      = "Run certbot for ${local.domains_csv}"

  timeout = "600" # 10 mins should be plenty
  environment {
    variables = {
      EMAILS  = local.emails_csv
      DOMAINS = local.domains_csv
      BUCKETS = local.buckets_csv
      REGION  = var.aws_region
    }
  }
}