
resource "aws_db_instance" "teamcity" {
  db_name               = var.name-simple
  engine                = "postgres"
  engine_version        = "13.4"
  instance_class        = "db.t3.small"
  allocated_storage     = 20
  max_allocated_storage = 100


  username = var.postgres_username
  password = var.postgres_password

  skip_final_snapshot = true

  #multi_az = true
  availability_zone = "${var.aws_region}a"

  publicly_accessible    = false
  vpc_security_group_ids = [aws_security_group.teamcity.id]
  db_subnet_group_name   = aws_db_subnet_group.private.id

  tags = merge(
    var.tags,
    { Name = "TeamCity" }
  )
}

resource "aws_db_subnet_group" "private" {
  name       = var.name-simple
  subnet_ids = [aws_subnet.public.id, aws_subnet.private.id]

  tags = merge(
    var.tags,
    { Name = "TeamCity" }
  )
}