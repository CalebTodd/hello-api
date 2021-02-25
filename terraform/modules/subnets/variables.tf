variable "namespace" {
  type        = string
  description = "Base naming concept"
}

variable "tags_common" {
  type        = map(string)
  description = "Common Tags to apply to each resource. `Name` is predetermined and appended to these."
}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC to use."
}

variable "igw_id" {
  type        = string
  description = "ID of the Internet Gateway to use."
}

variable "nat_gateway_enabled" {
  type        = bool
  description = "A boolean flag to enable/disable the creation of NAT gateway resources."
  default     = true
}

variable "update_default_route_table" {
  type        = bool
  description = "A boolean flag to determine whether the default route table for the VPC is updated to aws_route_table.private[0]"
  default     = true
}

variable "vpc_default_route_table_id" {
  type        = string
  description = "Default route table for public subnets. If not set, will be created. (e.g. `rtb-f4f0ce12`)"
  default     = ""
}

variable "max_subnet_count" {
  default     = 0
  description = "Sets the maximum amount of subnets to deploy.  0 will deploy a subnet for every provided availablility zone (in `availability_zones` variable) within the region"
}

variable "availability_zones" {
  type        = list(string)
  description = "List of Availability Zones where subnets will be created"
}

variable "cidrsubnet_newbits" {
  type        = number
  description = "This is the new mask for the subnet within the virtual network. For example, a `/16` CIDR with a newbits value of `4` equals a `/20`; a value of `5` equals `/21`, etc."
  default     = 4
}

# help: https://www.calculator.net/ip-subnet-calculator.html
variable "cidr_offset_public" {
  type        = number
  description = "A zero-based index for how many subnets to offset from the root of the VPC. Gets applied as `netnum` within the `cidrsubnet` function. This is to ensure private and public subnets do not overlap or to work around any existing subnets. The length of `availability_zones` will determine how many consecutive CIDR blocks are required."
}

# help: https://www.calculator.net/ip-subnet-calculator.html
variable "cidr_offset_private" {
  type        = number
  description = "A zero-based index for how many subnets to offset from the root of the VPC. Gets applied as `netnum` within the `cidrsubnet` function. This is to ensure private and public subnets do not overlap or to work around any existing subnets. The length of `availability_zones` will determine how many consecutive CIDR blocks are required."
}
