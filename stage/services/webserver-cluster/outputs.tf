# output "public_ip" {
#       value = aws_instance.terraform-example.public_ip
#       description = "public IP address of the web server"
# }

output "alb_dns_name" {
        value = aws_lb.example.dns_name
        description = "Domain name of the LB"
}


