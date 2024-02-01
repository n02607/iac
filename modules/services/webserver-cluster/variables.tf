variable "cluster_name" {
	description = "name for the certain cluster resource"
	type = string
}

variable "db_remote_state_bucket" {
        description = "name for S3 bucket that is for DB's remote state"
        type = string
}

variable "db_remote_state_key" {
        description = "path for the DB's remote state in S3"
        type = string
}


variable "instance_type" {
	description = "EC2 Instance-type to run (e.g. t2.micro)"
	type = string
}

variable "min_size" {
	description = "MIN EC2 instance numbers in the ASG"
	type = number
}
variable "max_size" {
	description = "MAX EC2 instance numbers in the ASG"
	type = number
}




# ==========================================================

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

data "terraform_remote_state" "db" {
        backend = "s3"
	config = {
		bucket = var.db_remote_state_bucket
                key = var.db_remote_state_key
		region = "ap-northeast-2"
	}
}    
