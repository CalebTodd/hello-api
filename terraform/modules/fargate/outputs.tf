output alb_dns_name {
  value       = aws_lb.main.dns_name
  description = "AWS-assigned DNS for the application load balancer"
}
