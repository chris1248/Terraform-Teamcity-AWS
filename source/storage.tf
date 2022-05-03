# General Notes:
# TeamCity stores its config data in a so called "data directory" at /data/teamcity_server/datadir
# When running teamcity in a docker container, if the docker container goes down
# the data would be lost, unless a volume is mounted to point to that "data directory"
#
# Luckily Amazon has instructions on how to mount an EFS volume to a Fargate Task:
# https://aws.amazon.com/premiumsupport/knowledge-center/ecs-fargate-mount-efs-containers-tasks/

resource "aws_efs_file_system" "data_storage" {
  creation_token = var.name


  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }
  lifecycle_policy {
    transition_to_primary_storage_class = "AFTER_1_ACCESS"
  }

  tags = merge(
    var.tags,
    { Name = "TeamCity" }
  )
}

resource "aws_efs_file_system_policy" "policy" {
  file_system_id                     = aws_efs_file_system.data_storage.id
  bypass_policy_lockout_safety_check = false

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Id" : "${var.name}Policy",
    "Statement" : [
      {
        "Sid" : "EFS-File-System-Policy",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "${aws_iam_role.ecs_task_role.arn}"
        },
        "Action" : [
          "elasticfilesystem:*"
        ]
        "Resource" : "${aws_efs_file_system.data_storage.arn}",
      }
    ]
  })
}

resource "aws_efs_mount_target" "mtarget_public" {
  file_system_id  = aws_efs_file_system.data_storage.id
  subnet_id       = aws_subnet.public.id
  security_groups = [aws_security_group.teamcity.id]
}

resource "aws_efs_mount_target" "mtarget_private" {
  file_system_id  = aws_efs_file_system.data_storage.id
  subnet_id       = aws_subnet.private.id
  security_groups = [aws_security_group.teamcity.id]
}

resource "aws_efs_access_point" "data_directory" {
  file_system_id = aws_efs_file_system.data_storage.id
  posix_user {
    uid            = var.user_id
    gid            = var.user_id
    secondary_gids = [1000, 1000]
  }
  root_directory {
    path = var.data_path

    creation_info {
      owner_uid   = var.user_id
      owner_gid   = var.user_id
      permissions = 777
    }
  }
  tags = merge(var.tags, { Name = "TeamCity" })
}

resource "aws_efs_access_point" "log_directory" {
  file_system_id = aws_efs_file_system.data_storage.id
  posix_user {
    uid            = var.user_id
    gid            = var.user_id
    secondary_gids = [1000, 1000]
  }
  root_directory {
    path = var.logs_path

    creation_info {
      owner_uid   = var.user_id
      owner_gid   = var.user_id
      permissions = 777
    }
  }
  tags = merge(var.tags, { Name = "TeamCity" })
}