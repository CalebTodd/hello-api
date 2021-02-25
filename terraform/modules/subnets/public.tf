locals {
  subnet_count_public = var.max_subnet_count == 0 ? length(var.availability_zones) : var.max_subnet_count
  cidr_block_public = cidrsubnet(
    data.aws_vpc.default.cidr_block,
    var.cidrsubnet_newbits,
    var.cidr_offset_public,
  )
  tags_public = {
    type = "public"
  }
}

# public subnet
resource "aws_subnet" "public" {
  count             = local.subnet_count_public
  vpc_id            = var.vpc_id
  availability_zone = element(var.availability_zones, count.index)
  cidr_block = cidrsubnet(
    data.aws_vpc.default.cidr_block,
    var.cidrsubnet_newbits,
    var.cidr_offset_public + count.index,
  )
  map_public_ip_on_launch = "true"

  tags = merge(
    {
      "Name" = "${var.namespace}-public-${element(var.availability_zones, count.index)}"
    },
    var.tags_common,
    local.tags_public,
  )

  timeouts {
    delete = "2m"
  }
}

# public route table
resource "aws_route_table" "public" {
  count  = signum(length(var.vpc_default_route_table_id)) == 1 ? 0 : 1
  vpc_id = var.vpc_id

  tags = merge(
    {
      "Name" = "${var.namespace}-public-${element(var.availability_zones, count.index)}"
    },
    var.tags_common,
    local.tags_public,
  )
}

# add route to the internet
resource "aws_route" "public_internet_gateway" {
  count                  = signum(length(var.vpc_default_route_table_id)) == 1 ? 0 : 1
  route_table_id         = aws_route_table.public[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = var.igw_id
}

## route table associations
# provisioned == associate public subnets to the route table provisioned by the module
resource "aws_route_table_association" "public_provisioned" {
  count          = signum(length(var.vpc_default_route_table_id)) == 1 ? 0 : local.subnet_count_public
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public[0].id
}

# provided == associate public subnets to the route table provided by the user
resource "aws_route_table_association" "public_provided" {
  count          = signum(length(var.vpc_default_route_table_id)) == 1 ? local.subnet_count_public : 0
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = var.vpc_default_route_table_id
}

