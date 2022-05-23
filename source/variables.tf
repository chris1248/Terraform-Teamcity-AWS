
variable name-simple {
  description = "The short alpha numeric name of the service"
  type        = string
}
variable name {
  description = "The name of the service"
  type        = string
}

variable aws_region {
  description = "The AWS region to create resources in"
  type        = string
}

variable teamcity-docker-image {
  description = "The docker image to pull from hub.docker.com"
  type        = string
}

variable java-options {
  description = "various java options to control the app"
  type        = string
}

variable fargate_cpu {
  description = "Fargate instance CPU units to provision (1 vCPU = 1024 CPU units)"
  type        = number
}

variable fargate_memory {
  description = "Fargate instance memory to provision (in MiB)"
  type        = number
}

variable app_port {
  description = "Port exposed by the docker image to redirect traffic to"
  type        = number
}

variable route_cidr_block {
  description = "The route table cidr block. It has to be greater than the VPC cidr block"
  type = string
}
variable vpc_cidr_block {
  description = "The CIDR block for the VPC"
  type = string
}

variable public_cidr_block {
  description = "The CIDR block for a public subnet"
  type = string
}

variable private_cidr_block {
  description = "The CIDR block for a private subnet"
  type = string
}

variable vpn_cidr_blocks {
  description = "A security measure to limit exposer of teamcity only to machines in a particular CIDR range"
  type        = list(string)
}

variable tags {
  description = "Tags for the ECS resources"
  type        = map(string)
}

variable data_path {
  description = "The path inside the container to mount to an EFS volume"
  type        = string
}

variable logs_path {
  description = "The path inside the container where logs get stored"
  type        = string
}

variable user_id {
  description = "A User the author of the container requested to use"
  type        = number
}

variable postgres_username {
  description = "An admin name for the postgress administrator"
  type = string
}

variable postgres_password {
  description = "An admin password for the postgress administrator"
  type = string
}

variable cert_domain {
  description = "certificate domain"
  type = string
}