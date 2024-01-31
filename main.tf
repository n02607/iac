provider  "aws" {
  region = "ap-northeast-2" 

}

resource "aws_launch_configuration" "terraform-example" {
	image_id = "ami-0f3a440bbcff3d043"
	instance_type = "t3.micro"
	security_groups = [aws_security_group.terraform-sg-exmaple.id]

	lifecycle {
		create_before_destroy = true
	}
	
	user_data = <<-EOF
		#!/bin/bash
		echo "Hello, Terraform" > index.html
		nohup busybox httpd -f -p ${var.server_port} &
		EOF
}

resource "aws_security_group" "terraform-sg-exmaple" {

	name = "tf-sg"

	ingress {
		from_port = var.server_port
		to_port = var.server_port
		protocol = "tcp"
		cidr_blocks = [ "0.0.0.0/0" ]
	}

}

variable "server_port" {
	description = "port for the server to get HTTP requests"
	type = number
	default = 8080
}

data "aws_vpc" "default" {
	default = true
}

data "aws_subnets" "default" {
	filter {
		name = "vpc-id"
		values = [data.aws_vpc.default.id]
	}
}

# output "public_ip" {
#	value = aws_instance.terraform-example.public_ip
#	description = "public IP address of the web server"
# }

resource "aws_autoscaling_group" "terraform-asg-example" {
	launch_configuration = aws_launch_configuration.terraform-example.name
	min_size = 2
	max_size = 6
	tag {
			key = "Name"
		value = "teraaform_asg-example"
		propagate_at_launch = true
	}
	
	vpc_zone_identifier = data.aws_subnets.default.ids
	target_group_arns = [aws_lb_target_group.asg.arn]
}

resource "aws_lb" "example" {
	name = "terraform-asg-example"
	load_balancer_type = "application"
	subnets = data.aws_subnets.default.ids
	security_groups = [aws_security_group.alb.id]
}

resource "aws_lb_listener" "http" {
	load_balancer_arn = aws_lb.example.arn
	port = 80
	protocol = "HTTP"
	
	default_action {
		type = "fixed-response"
		
		fixed_response {
			content_type = "text/plain"
			status_code = 404
		}
	}
}

resource "aws_security_group" "alb" {
	name = "terraform-example-alb"
	
	# Allow inbound HTTP req
	ingress {
		from_port = 80
		to_port = 80
		protocol = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
	}
	
	# Allow all outbound req
	egress {
		from_port = 0
		to_port =0
		protocol = "-1"
		cidr_blocks = ["0.0.0.0/0"]
	}
}


resource "aws_lb_target_group" "asg" {
	name = "terraform-asg-example"
	port = var.server_port
	protocol = "HTTP"
	vpc_id = data.aws_vpc.default.id
	health_check {
		path = "/"
		protocol = "HTTP"
		matcher = "200"
		interval = 15
		timeout = 3
		healthy_threshold = 2
		unhealthy_threshold = 2	
	}
}

resource "aws_lb_listener_rule" "asg" {
	listener_arn = aws_lb_listener.http.arn
	priority = 100
	condition {
		path_pattern {
			values = ["*"]
		}
	}
	action {
		type = "forward"
		target_group_arn = aws_lb_target_group.asg.arn
	}

}

output "alb_dns_name" {
	value = aws_lb.example.dns_name
	description = "Domain name of the LB"
}
