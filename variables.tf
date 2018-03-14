data "aws_availability_zones" "azs" {}

variable region {
  default = "us-east-1"
}

variable "prefix" {
  default = "demo"
}

variable "cidr_block" {
  default = "10.0.0.0/16"
  description = "The cidr block of the desired VPC."
}
