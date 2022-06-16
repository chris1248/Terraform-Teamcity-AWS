resource aws_ecs_task_definition app {
  family                   = var.name
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  tags                     = var.tags

  container_definitions = jsonencode([
    {
      "cpu" : var.fargate_cpu,
      "image" : var.teamcity-docker-image
      "memory" : var.fargate_memory,
      "mountPoints" : [],
      "name" : "${var.name}-def",
      "environment" : [
        { "name" : "TEAMCITY_SERVER_MEM_OPT", "value" : "${var.java-options}" }
      ],
      "essential" : true,
      "portMappings" : [
        {
          "containerPort" : var.app_port,
          "hostPort" : var.app_port,
          "protocol" : "tcp"
        }
      ],
      "mountPoints" : [
        {
          "sourceVolume" : "${var.name}-storage",
          "containerPath" : "${var.data_path}",
          "readOnly" : false
        }
      ],
      "logConfiguration" : {
        "logDriver" : "awslogs",
        "options" : {
          "awslogs-group" : "${aws_cloudwatch_log_group.logs.name}",
          "awslogs-region" : "${var.aws_region}",
          "awslogs-stream-prefix" : "teamcity"
        }
      },
      "healthCheck" : {
        "retries" : 3,
        "command" : [
          "CMD-SHELL",
          "curl -f http://localhost:${var.app_port}/mnt/get/stateRevision || exit 1"
        ],
        "timeout" : 5,
        "interval" : 60,
        "startPeriod" : null
      }
    }
  ])

  volume {
    name = "${var.name}-storage"
    efs_volume_configuration {
      file_system_id          = aws_efs_file_system.data_storage.id
      root_directory          = var.data_path
      transit_encryption      = "ENABLED"
      transit_encryption_port = 2999
      authorization_config {
        access_point_id = aws_efs_access_point.data_directory.id
        iam             = "ENABLED"
      }
    }
  }
}

resource aws_ecs_cluster main {
  name = var.name
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
  tags = var.tags
}

resource aws_ecs_service main {
  name            = var.name
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  depends_on      = [data.aws_iam_policy.efs_task_exec_policy]
  tags            = var.tags
  network_configuration {
    security_groups  = [aws_security_group.teamcity.id]
    subnets          = [aws_subnet.public.id]
    assign_public_ip = true
  }
}
