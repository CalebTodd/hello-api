output "vpc_id" {
  value = aws_vpc.main.id
}

output "igw_id" {
  value = aws_internet_gateway.main.id
}

output default_sg {
  value = aws_default_security_group.default.id
}
