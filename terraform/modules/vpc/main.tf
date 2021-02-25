locals {
  tags_vpc = "${merge(
    map("Name", "${var.namespace}-vpc"),
    "${var.tags_common}"
  )}"

  tags_igw = "${merge(
    map("Name", "${var.namespace}-igw"),
    "${var.tags_common}"
  )}"

}

# vpc
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support
  tags                 = local.tags_vpc
}

# default sg <-- not managing directly
resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.main.id

  ingress {
    protocol  = -1
    self      = true
    from_port = 0
    to_port   = 0
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# internet gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags   = local.tags_igw
}
