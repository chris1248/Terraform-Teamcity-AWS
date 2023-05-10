# https://mxtoolbox.com/subnetcalculator.aspx
resource aws_vpc main {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true
  tags = merge(
    var.tags,
    { Name = "TeamCity-VPC" }
  )
}

resource aws_security_group teamcity {
  name        = var.name
  description = "Allow https inbound traffic"
  vpc_id      = aws_vpc.main.id

  # To allow inbound connections from customers of the app
  ingress {
    description = "For VPN traffic"
    from_port   = var.app_port
    to_port     = var.app_port
    protocol    = "tcp"
    cidr_blocks = var.vpn_cidr_blocks # Machines within the company VPN
  }

  ingress {
    description = "For RDS Postgres traffic"
    from_port   = var.postgres_port
    to_port     = var.postgres_port
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }

  # To allow inbound connections on port 2049 (Network File System, or NFS) from the security group associated with your Fargate task or service
  ingress {
    description = "Listen to EFS"
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # TODO, replace this
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    description = "Talk to EFS"
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # TODO, replace this
  }

  tags = var.tags
}

resource aws_subnet public {
  vpc_id            = aws_vpc.main.id
  availability_zone = "${var.aws_region}${var.aws_azone_public}"
  cidr_block = var.public_cidr_block

  tags = var.tags
}

resource aws_subnet private {
  vpc_id            = aws_vpc.main.id
  availability_zone = "${var.aws_region}${var.aws_azone_private}"
  cidr_block = var.private_cidr_block

  tags = var.tags
}

resource aws_internet_gateway gateway {
  vpc_id = aws_vpc.main.id

  tags = var.tags
}

resource aws_route_table router {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = var.route_cidr_block
    gateway_id = aws_internet_gateway.gateway.id
  }

  # Needed for ECS to pull the teamcity image from docker.io
  route {
    cidr_block = "0.0.0.0/0" # TODO, replace this, or limit it
    gateway_id = aws_internet_gateway.gateway.id
  }

  tags = var.tags
}

resource aws_route_table_association private_link {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.router.id
}

resource aws_route_table_association public_link {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.router.id
}