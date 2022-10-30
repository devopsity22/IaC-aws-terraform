# IaC-aws-terraform

In this project I'm going show you how to provision your infrastructure on AWS using Terraform. A new VPC with 3 public subnets will be created, one subnet per availability zone and one EC2 instance on each subnet will be created. An Internet gateway and a route table will allow every EC2 instance to access Internet. An Apache server will be installed on each EC2 instance and a classic load balancer will distribute traffic between those 3 EC2 instances
