terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.11.0"
    }
  }
}

provider aws {
  region = var.aws_region
}

resource aws_cloudwatch_log_group logs {
  name              = "/fargate/service/${var.name}"
  tags              = var.tags
  retention_in_days = 30
}

