# -------------------------------------
# Task Execution Role & Policy
#
# This role is not used by the task itself. 
# Instead, it is used by the ECS agent and container runtime 
# environment to prepare the containers to run.
# -------------------------------------

resource "aws_iam_role" "ecs_task_execution_role" {
  name        = "TeamCityServerRole-execute"
  description = "# This role is required by tasks to pull container images and publish container logs to Amazon CloudWatch on your behalf"
  tags        = var.tags
  # 12 hour duration
  max_session_duration = 43200
  assume_role_policy   = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

data "aws_iam_policy" "efs_task_exec_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy_attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = data.aws_iam_policy.efs_task_exec_policy.arn
}


# -------------------------------------
# Task Role & Policy
#
# In contrast to the task execution role, the task role grants additional
# AWS permissions required by your application once the container is started. 
# This is only relevant if your container needs access to other AWS resources, 
# such as S3 or DynamoDB or other stuff 
# -------------------------------------

resource "aws_iam_role" "ecs_task_role" {
  name        = "TeamCityServerRole"
  description = "Permissions for the TeamCity Server application"
  tags        = var.tags
  # 12 hour duration
  max_session_duration = 43200
  assume_role_policy   = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

data "aws_iam_policy" "efs_full_access_policy" {
  arn = "arn:aws:iam::aws:policy/AmazonElasticFileSystemFullAccess"
}

data "aws_iam_policy" "efs_client_access_policy" {
  arn = "arn:aws:iam::aws:policy/AmazonElasticFileSystemClientFullAccess"
}
resource "aws_iam_role_policy_attachment" "role_full_attachment" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = data.aws_iam_policy.efs_full_access_policy.arn
}

resource "aws_iam_role_policy_attachment" "role_client_attachment" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = data.aws_iam_policy.efs_client_access_policy.arn
}