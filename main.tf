# Network

data "aws_availability_zones" "available" {}

resource "aws_vpc" "default" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags {
    Name = "${var.name}-vpc"
  }
}

resource "aws_subnet" "private" {
  vpc_id = "${aws_vpc.default.id}"

  count = "${length(data.aws_availability_zones.available.names)}"
  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"

  cidr_block = "${cidrsubnet(  aws_vpc.default.cidr_block, ceil(log(length(data.aws_availability_zones.available.names) * 2, 2)), count.index)}"
  //map_public_ip_on_launch = true

  tags {
    Name = "${var.name}-private"
  }
}

resource "aws_subnet" "public" {
  vpc_id = "${aws_vpc.default.id}"

  count = "${length(data.aws_availability_zones.available.names)}"
  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"

  cidr_block = "${cidrsubnet(   aws_vpc.default.cidr_block, ceil(log(length(data.aws_availability_zones.available.names) * 2, 2)), length(data.aws_availability_zones.available.names) + count.index)}"
  map_public_ip_on_launch = true

  tags {
    Name = "${var.name}-public"
  }
}

resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.default.id}"

  tags {
    Name = "${var.name}"
  }
}

resource "aws_route_table" "default" {
  vpc_id = "${aws_vpc.default.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.default.id}"
  }

  tags {
    Name = "${var.name}"
  }
}

resource "aws_route_table_association" "main" {
  count = "${length(data.aws_availability_zones.available.names)}"
  subnet_id = "${element(aws_subnet.public.*.id, count.index)}"
  route_table_id = "${aws_route_table.default.id}"
}

# Security Group

resource "aws_security_group" "ssh" {
  name = "${var.name}-ssh"
  description = "for ${var.name}-vpc (tf)"

  vpc_id = "${aws_vpc.default.id}"

  # SSH access from anywhere
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  # outbound internet access
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  # ensure the VPC has an Internet gateway or this step will fail
  depends_on = [
    "aws_internet_gateway.default",
  ]
}

resource "aws_security_group" "web" {
  name = "${var.name}-web"
  description = "for ${var.name}-vpc (tf)"

  vpc_id = "${aws_vpc.default.id}"

  # HTTP access from anywhere
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  # outbound internet access
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  # ensure the VPC has an Internet gateway or this step will fail
  depends_on = [
    "aws_internet_gateway.default",
  ]
}
