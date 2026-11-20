data "aws_iam_policy_document" "ecs_tasks_assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "execution" {
  name               = "task-3-47-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_assume.json
}

resource "aws_iam_role_policy_attachment" "execution" {
  role       = aws_iam_role.execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "task" {
  name               = "task-3-47-task-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_assume.json
}

# Uncomment only if the Streamlit app reads one known bucket.
# resource "aws_iam_role_policy" "task_s3_read" {
#   name = "task-3-47-task-s3-read"
#   role = aws_iam_role.task.id
#
#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Sid      = "ListAppBucket"
#         Effect   = "Allow"
#         Action   = ["s3:ListBucket"]
#         Resource = "arn:aws:s3:::YOUR-BUCKET"
#       },
#       {
#         Sid      = "ReadAppObjects"
#         Effect   = "Allow"
#         Action   = ["s3:GetObject"]
#         Resource = "arn:aws:s3:::YOUR-BUCKET/*"
#       }
#     ]
#   })
# }
