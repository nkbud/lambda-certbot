
resource "aws_iam_role" "x" {
  name = local.app_name
  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Action" : "sts:AssumeRole",
          "Principal" : {
            "Service" : "lambda.amazonaws.com"
          },
          "Effect" : "Allow"
        }
      ]
    }
  )
}
resource "aws_iam_role_policy_attachment" "logs" {
  role       = aws_iam_role.x.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "x" {
  role       = aws_iam_role.x.name
  policy_arn = aws_iam_policy.x.arn
}
resource "aws_iam_policy" "x" {
  name        = local.app_name
  description = "Allow ${local.app_name} access to s3, route53"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:ListBucket"
        ],
        Resource = [
          for bucket in local.bucket_set :
          "arn:aws:s3:::${bucket}"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "s3:PutObject"
        ],
        Resource = [
          for bucket in local.bucket_set :
          "arn:aws:s3:::${bucket}/*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "route53:ListHostedZones",
          "route53:GetChange",
          "route53:ChangeResourceRecordSets"
        ],
        Resource = "*"
      }
    ]
  })
}
