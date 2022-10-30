variable "vpc_name" {
  type    = string
  default = "vpc-terraform"
}

variable "vpc_bloc" {
  type    = string
  default = "10.0.0.0/16"
}

variable "subnet_blocs" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "availability_zones" {
  type    = list(string)
  default = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
}

variable "subnet_names" {
  type    = list(string)
  default = ["subnet_az1", "subnet_az2", "subnet_az3"]
}

variable "igw_name" {
  type    = string
  default = "int_gateway"
}

variable "sg_name" {
  type    = string
  default = "my-sg"
}

variable "key_name" {
  type    = string
  default = "ec2-key-pair"
}

variable "ec2_type" {
  type    = string
  default = "t2.micro"
}

variable "elb_name" {
  type    = string
  default = "terraform-elb"
}