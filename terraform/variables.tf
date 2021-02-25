variable "namespace" {
  type = string
}

variable "app_name" {
  type = string
}

variable "tags_common" {
  type        = map(string)
  description = "Common Tags to apply to each resource."
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR the VPC will use."
}

variable "availability_zones" {
  type        = list(string)
  description = "List of Availability Zones where subnets will be created"
}

variable "db_user" {
  type        = string
  description = "The user account to use for the database connection"
}

variable "db_password" {
  type        = string
  description = "The password correlating to the user account to use for the database connection"
}

variable "db_name" {
  type        = string
  description = "The name of the database to use for the database connection"
}

variable "db_host" {
  type        = string
  description = "The hostname to use for the database connection"
}

variable "app_port" {
  type        = number
  description = "The port on which the application will listen"
}

variable "image_tag" {
  type        = string
  description = "The desired image tag to use for the ECR Container Image in the Task Definition"
}
