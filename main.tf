# Network

data "aws_availability_zones" "available" {}

resource "aws_vpc" "default" {
  cidr_block = "${var.cidr_block}"
  enable_dns_hostnames = true

  tags {
    Name = "${var.prefix}-vpc"
  }
}

resource "aws_subnet" "private" {
  vpc_id = "${aws_vpc.default.id}"

  count = "${length(data.aws_availability_zones.available.names)}"
  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"

  cidr_block = "${cidrsubnet(aws_vpc.default.cidr_block, 8, count.index)}"
  map_public_ip_on_launch = true

  tags {
    Name = "${var.prefix}-private"
  }
}

resource "aws_subnet" "public" {
  vpc_id = "${aws_vpc.default.id}"

  count = "${length(data.aws_availability_zones.available.names)}"
  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"

  cidr_block = "${cidrsubnet(aws_vpc.default.cidr_block, 8, 10 + count.index)}"
  map_public_ip_on_launch = true

  tags {
    Name = "${var.prefix}-public"
  }
}

resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.default.id}"

  tags {
    Name = "${var.prefix}"
  }
}

resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.default.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.default.id}"
  }

  tags {
    Name = "${var.prefix}-public"
  }
}

resource "aws_route_table" "private" {
  vpc_id = "${aws_vpc.default.id}"

  route {
    cidr_block = "0.0.0.0/0"
  }

  tags {
    Name = "${var.prefix}-private"
  }
}

resource "aws_route_table_association" "public" {
  count = "${length(data.aws_availability_zones.available.names)}"
  subnet_id = "${element(aws_subnet.public.*.id, count.index)}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_route_table_association" "private" {
  count = "${length(data.aws_availability_zones.available.names)}"
  subnet_id = "${element(aws_subnet.private.*.id, count.index)}"
  route_table_id = "${aws_route_table.private.id}"
}

# Security Group

resource "aws_security_group" "ssh" {
  name = "${var.prefix}-ssh"
  description = "for ${var.prefix}-vpc"

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
  name = "${var.prefix}-web"
  description = "for ${var.prefix}-vpc"

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
