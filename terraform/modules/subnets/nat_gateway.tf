locals {
  nat_gateways_count = var.nat_gateway_enabled == true ? length(var.availability_zones) : 0
}

# NAT gateway EIPs
resource "aws_eip" "nat" {
  count = local.nat_gateways_count
  vpc   = true

  tags = merge(
    {
      "Name" = "${var.namespace}-nat-${element(var.availability_zones, count.index)}"
    },
    var.tags_common,
  )

  lifecycle {
    create_before_destroy = true
  }
}

# NAT gateway
resource "aws_nat_gateway" "default" {
  count         = local.nat_gateways_count
  allocation_id = element(aws_eip.nat.*.id, count.index)
  subnet_id     = element(aws_subnet.public.*.id, count.index)

  tags = merge(
    {
      "Name" = "${var.namespace}-nat-${element(var.availability_zones, count.index)}"
    },
    var.tags_common,
  )

  lifecycle {
    create_before_destroy = true
  }
}

# NAT route
resource "aws_route" "nat" {
  count                  = local.nat_gateways_count
  depends_on             = [aws_route_table.private]
  route_table_id         = element(aws_route_table.private.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.default.*.id, count.index)
}