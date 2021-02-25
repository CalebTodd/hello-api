locals {
  subnet_count_private = var.max_subnet_count == 0 ? length(var.availability_zones) : var.max_subnet_count
  cidr_block_private = cidrsubnet(
    data.aws_vpc.default.cidr_block,
    var.cidrsubnet_newbits,
    var.cidr_offset_private,
  )
  tags_private = {
    type = "private"
  }
}

# private subnet
resource "aws_subnet" "private" {
  count             = local.subnet_count_private
  vpc_id            = var.vpc_id
  availability_zone = element(var.availability_zones, count.index)
  cidr_block = cidrsubnet(
    data.aws_vpc.default.cidr_block,
    var.cidrsubnet_newbits,
    var.cidr_offset_private + count.index,
  )

  tags = merge(
    {
      "Name" = "${var.namespace}-private-${element(var.availability_zones, count.index)}"
    },
    var.tags_common,
    local.tags_private,
  )
}

# route table for private subnet
resource "aws_route_table" "private" {
  count  = local.subnet_count_private
  vpc_id = var.vpc_id

  tags = merge(
    {
      "Name" = "${var.namespace}-private-${element(var.availability_zones, count.index)}"
    },
    var.tags_common,
    local.tags_private,
  )
}

# route table association - private
resource "aws_route_table_association" "private" {
  count          = local.subnet_count_private
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(aws_route_table.private.*.id, count.index)
}

# replacing VPC main route table with first private subnet
resource "aws_main_route_table_association" "main" {
  count          = var.update_default_route_table ? 1 : 0
  vpc_id         = var.vpc_id
  route_table_id = element(aws_route_table.private.*.id, 0)
}
