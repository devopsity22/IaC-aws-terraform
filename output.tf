output "ami_id" {
  value = data.aws_ami.my_image.id
}

output "webservers_ip" {
  value = [for instance in aws_instance.webserver : instance.public_ip]
}

output "elb_dns_name" {
  value = aws_elb.load_balancer.dns_name
}