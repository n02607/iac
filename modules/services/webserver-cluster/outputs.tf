output "alb_dns_name" {
        value = aws_lb.example.dns_name
        description = "Domain name of the ALB"
}

output "asg_name" {
	value = aws_autoscaling_group.terraform-asg-example.name
	description = "name of the ASG"
}

output "alb_security_group_id" {
	value = aws_security_group.alb.id
	description = "ID of the SG attached to the ALB"
}
