variable "namespace" {
  type        = string
  description = "Base naming concept"
}

variable "tags_common" {
  type        = map(string)
  description = "Common Tags to apply to each resource. `Name` is predetermined and appended to these."
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR the VPC will use."
}

variable "enable_dns_support" {
  type        = bool
  description = "A boolean flag to enable/disable DNS hostnames in the VPC."
  default     = true
}

variable "enable_dns_hostnames" {
  type        = bool
  description = "A boolean flag to enable/disable DNS hostnames in the VPC."
  default     = true
}
