# Terraform-Terraform-AWS
Terraform to setup TeamCity on AWS resources

# Introduction
This code sets up a single TeamCity Server to run on Amazon ECS (running in fargate).  
This works by specifying an official JetBrains Teamcity docker image, and running it in a Cluster on ECS. 
This runs only one task in ECS running in the cluster. ECS gives us the nice benefit of automatically rebooting the server if the health checks determine the server is unhealthy.

# Terraform code
The terraform code creates all the necessary infrastructure for the server to run safely and reliably. For instance it sets up 
1. VPC networks
2. IAM roles and policies
3. Persistent storage using EFS (So in case of a reboot, all settings are not lost)
4. RDS postgres database

There are quite a few required inputs for terraform that can be passed in various ways. 
These ways are:
1. Type in the variables using the command line when executing `terraform apply`. But really this is very tedious, who does this anymore?
2. Create a *.tfvars file and pass it in when doing apply: `terraform apply -var-file="file.tfvars"`
3. Create a file with a standard name called *terraform.tfvars*. Terraform will automatically look for it when executing `terraform apply`.

Jetbrains TeamCity requires a database for it's internal operations. Jetbrains does supply its own internal database if you want to use it. But it is not recommended, since when the docker image gets shut down all data will be lost. This is definitely not good.
Therefore Jetbrains recommends using an external Database. This terraform code specifies an RDS database running postgres. Currently the RDS database has no redundancy, but in that future I will change that since presently I want to keep costs down.

The file variables.tf lists the required variables to input into the system. I don't recommend putting the postgres username and password into a terraform *.tfvars file. Just enter those in manually when running terraform apply. (And don't forget them!!)