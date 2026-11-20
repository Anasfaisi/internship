
provider "aws" {
  region = var.aws_region
}

# 1. Trust policy: allows EC2 to assume this role
data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# 2. IAM Role
resource "aws_iam_role" "app_role" {
  name               = "task-3-42-app-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
}

# 3. Customer managed S3 policy
data "aws_iam_policy_document" "custom_s3" {
  statement {
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:ListBucket"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "custom_s3" {
  name        = "task-3-42-custom-s3-policy"
  description = "Allows S3 object reads and bucket listing"
  policy      = data.aws_iam_policy_document.custom_s3.json
}

# 4. Attach customer managed policy to role
resource "aws_iam_role_policy_attachment" "custom_s3" {
  role       = aws_iam_role.app_role.name
  policy_arn = aws_iam_policy.custom_s3.arn
}

# 5. Inline CloudWatch Logs policy
data "aws_iam_policy_document" "cloudwatch_inline" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "cloudwatch_inline" {
  name   = "task-3-42-cloudwatch-inline-policy"
  role   = aws_iam_role.app_role.id
  policy = data.aws_iam_policy_document.cloudwatch_inline.json
}

# 6. Reference AWS managed policy
data "aws_iam_policy" "s3_readonly" {
  arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

# 7. Attach AWS managed policy to role
resource "aws_iam_role_policy_attachment" "s3_readonly" {
  role       = aws_iam_role.app_role.name
  policy_arn = data.aws_iam_policy.s3_readonly.arn
}
