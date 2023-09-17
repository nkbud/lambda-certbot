
variable "aws_region" {}

variable "domains" {
  type = list(string)
}
variable "emails" {
  type = list(string)
}
variable "buckets" {
  type = list(string)
}

locals {
  domains_csv = join(",", var.domains)
  emails_csv  = join(",", var.emails)
  buckets_csv = join(",", var.buckets)

  bucket_set = toset(var.buckets)
  # give lambda permission to each bucket

  lambda_filename = "${path.module}/lambda-certbot.zip"
  lambda_hash     = filebase64sha256(local.lambda_filename)
}