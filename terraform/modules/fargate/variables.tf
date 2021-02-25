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

variable "vpc_id" {
  type        = string
  description = "ID of the VPC to use."
}

variable container_definitions {
  type        = string
  description = "A list of valid container definitions provided as a single valid JSON document."
}

variable "app_port" {
  type        = number
  description = "The port on which the application will listen"
}

variable "efs_sourceVolume" {
  type        = string
  description = "The name of the EFS volume the container definition specifies"
}

