# Network

resource "aws_vpc" "default" {
  cidr_block = "${var.cidr_block}"
  enable_dns_hostnames = true

  tags {
    Name = "${var.prefix}-vpc"
  }
}

resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.default.id}"

  tags {
    Name = "${var.prefix}-igw"
  }
}

resource "aws_subnet" "private" {
  vpc_id = "${aws_vpc.default.id}"

  count = "${length(data.aws_availability_zones.azs.names)}"
  availability_zone = "${data.aws_availability_zones.azs.names[count.index]}"

  cidr_block = "${cidrsubnet(aws_vpc.default.cidr_block, 8, 10 + count.index)}"
  map_public_ip_on_launch = true

  tags {
    Name = "${var.prefix}-private"
  }
}

resource "aws_subnet" "public" {
  vpc_id = "${aws_vpc.default.id}"

  count = "${length(data.aws_availability_zones.azs.names)}"
  availability_zone = "${data.aws_availability_zones.azs.names[count.index]}"

  cidr_block = "${cidrsubnet(aws_vpc.default.cidr_block, 8, 20 + count.index)}"
  map_public_ip_on_launch = true

  tags {
    Name = "${var.prefix}-public"
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

  tags {
    Name = "${var.prefix}-private"
  }
}

resource "aws_route_table_association" "public" {
  count = "${length(data.aws_availability_zones.azs.names)}"
  subnet_id = "${element(aws_subnet.public.*.id, count.index)}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_route_table_association" "private" {
  count = "${length(data.aws_availability_zones.azs.names)}"
  subnet_id = "${element(aws_subnet.private.*.id, count.index)}"
  route_table_id = "${aws_route_table.private.id}"
}
