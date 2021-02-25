output "initial_cidr_public" {
  value = local.cidr_block_public
}

output "initial_cidr_private" {
  value = local.cidr_block_private
}

output "subnet_route_tables_private" {
  value = aws_route_table.private.*.id
}

output "subnets_private_id" {
  value = aws_subnet.private.*.id
}

output "subnets_public_id" {
  value = aws_subnet.public.*.id
}
