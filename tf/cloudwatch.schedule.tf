
resource "aws_cloudwatch_event_rule" "schedule" {
  name                = "${aws_lambda_function.certbot.function_name}-weekly"
  description         = "Triggers lambda function ${aws_lambda_function.certbot.function_name}, weekly."
  schedule_expression = "rate(7 days)"
}

resource "aws_cloudwatch_event_target" "schedule" {
  rule  = aws_cloudwatch_event_rule.schedule.name
  arn   = aws_lambda_function.certbot.arn
  input = "{}"
}

resource "aws_lambda_permission" "schedule" {
  source_arn    = aws_cloudwatch_event_rule.schedule.arn
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.certbot.function_name
  principal     = "events.amazonaws.com"
}
