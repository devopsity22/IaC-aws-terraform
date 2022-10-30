terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {}

# grab most recent AMI
data "aws_ami" "my_image" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Create a new VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = var.vpc_bloc

  tags = {
    Name = var.vpc_name
  }
}

# Create three subnets inside the VPC
resource "aws_subnet" "my_subnets" {
  count             = length(var.subnet_blocs)
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = var.subnet_blocs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = var.subnet_names[count.index]
  }
  map_public_ip_on_launch = true
}

# Create an Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = var.igw_name
  }
}

# Create a route in the default table pointing all
# traffic to the internet gateway
resource "aws_default_route_table" "default_route_table" {
  default_route_table_id = aws_vpc.my_vpc.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

# Associate the route table to each subnet
resource "aws_route_table_association" "subnet_table_association" {
  count          = length(var.subnet_blocs)
  subnet_id      = aws_subnet.my_subnets[count.index].id
  route_table_id = aws_vpc.my_vpc.default_route_table_id
}

# Adding inbound rules to the default security group
resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.my_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.sg_name
  }
}

# Create EC2 instances
resource "aws_instance" "webserver" {
  ami                    = data.aws_ami.my_image.id
  key_name               = var.key_name
  instance_type          = var.ec2_type
  vpc_security_group_ids = [aws_default_security_group.default.id]
  user_data              = file("script/bootstrap.sh")

  count     = length(aws_subnet.my_subnets)
  subnet_id = aws_subnet.my_subnets[count.index].id

  tags = {
    Name = "webserver-${count.index + 1}"
  }
}

# Create a new load balancer
resource "aws_elb" "load_balancer" {
  name            = var.elb_name
  subnets         = [for subnet in aws_subnet.my_subnets : subnet.id]
  security_groups = [aws_default_security_group.default.id]
  instances       = [for instance in aws_instance.webserver : instance.id]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
}