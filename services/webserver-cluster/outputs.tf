output "public_ip" {
  description = "The public IPv4 address of the web server"
  value       = aws_instance.example.public_ip
}

output "instance_id" {
  description = "The Instance ID"
  value       = aws_instance.example.id
}

output "alb_dns_name" {
  description = "The domain name of the load balancer"
  value       = aws_lb.example.dns_name
}

output "asg_name" {
  description = "The name of the Auto Scaling Group"
  value       = aws_autoscaling_group.example.name
}

output "alb_security_group_id" {
  description = "The ID of the Security Group attached to the load balancer"
  value       = aws_security_group.alb.id
}

output "user_data" {
  value = aws_launch_template.example.user_data
}

output "ami" {
  value = aws_launch_template.example.image_id
}