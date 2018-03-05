data "aws_availability_zones" "available" {}

variable region {
  default = "us-east-1"
}

variable "prefix" {
  default = "demo"
}

variable "cidr_block" {
  default = "10.0.0.0/16"
}
