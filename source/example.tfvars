name-simple           = "teamcity"
name                  = "teamcity-server"
aws_region            = "us-east-1"
aws_azone_public      = "a"
aws_azone_private     = "b"
data_path             = "/data/teamcity_server/datadir"
logs_path             = "/opt/teamcity/logs"
teamcity-docker-image = "jetbrains/teamcity-server:latest"
java-options          = "-Xmx2g -XX:MaxPermSize=270m -XX:ReservedCodeCacheSize=350m"
vpc_cidr_block       = "10.0.0.0/27"
public_cidr_block     = "10.0.0.0/28"
private_cidr_block    = "10.0.0.16/28"
# This is used if you want your TeamCity Server to only be available behind a corporate VPN.
# Specify a list of CIDR blocks here
vpn_cidr_blocks       = ["1.2.3.4/28", "1.0.0.0/28"]
fargate_cpu           = 2048
fargate_memory        = 4096
app_port              = 8111
user_id               = 1000
# Enter in extra tags you want to tag all your resources with
tags = {
  Company         = "Example Company"
  Team            = "Example Team"
  Product         = "Example Product"
}