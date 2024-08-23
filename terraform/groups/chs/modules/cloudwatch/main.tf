resource "aws_cloudwatch_log_group" "monitoring" {
  name              = var.service_name
  retention_in_days = var.retention_in_days

  tags = var.tags
}

resource "aws_cloudwatch_query_definition" "fr_connectors_query" {
  name = "fr_connectors"

  log_group_names = [
    "/aws/lambda/cwsyn-fr-connectors-5f03d36d-38d5-4013-9702-e215c42e9f48"
  ]

  query_string = <<EOF
fields @timestamp, @message
| filter @message like /Failure reason:/
| parse @message "[*]\"Failure reason:\": \"*\"" as Count, Error
| stats sum(min(Count)) by Error as CT 
EOF
}

resource "aws_s3_bucket" "canary_artifacts" {
  bucket        = "${var.environment}-${var.region}.${var.service_name}.ch.gov.uk"
  force_destroy = true

  tags = var.tags
}

data "aws_iam_policy_document" "canary_role" {
  version = "2012-10-17"
  statement {
    sid     = ""
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "canary_role" {
  name               = "${var.service_name}-canary"
  assume_role_policy = data.aws_iam_policy_document.canary_role.json

  tags = var.tags
}

resource "aws_iam_policy" "canary_role" {
  name = "${var.service_name}-canary"
  path = "/"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:PutObject",
        ]
        Effect   = "Allow"
        Resource = "${aws_s3_bucket.canary_artifacts.arn}/*"
      },
      {
        Action = [
          "s3:GetBucketLocation",
        ]
        Effect   = "Allow"
        Resource = aws_s3_bucket.canary_artifacts.arn
      },
      {
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:CreateLogGroup",
        ]
        Effect   = "Allow"
        Resource = "arn:aws:logs:::*"
      },
      {
        Action = [
          "s3:ListAllMyBuckets",
        ]
        Effect = "Allow"
        Resource = "arn:aws:s3:::"
      },
      {
        Action = [
          "cloudwatch:PutMetricData",
        ]
        Effect = "Allow"
        Resource = "arn:aws:cloudwatch:::"
      },

    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "canary_role" {
  role       = aws_iam_role.canary_role.name
  policy_arn = aws_iam_policy.canary_role.arn
}
