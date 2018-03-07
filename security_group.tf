# Security Group

resource "aws_security_group" "self" {
  name = "${var.prefix}-self"
  description = "for ${var.prefix}-vpc"

  vpc_id = "${aws_vpc.default.id}"

  # SELF
  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    self = true
  }

  # outbound internet access
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    self = true
  }

  # ensure the VPC has an Internet gateway or this step will fail
  depends_on = [
    "aws_internet_gateway.default",
  ]
}

resource "aws_security_group" "ssh" {
  name = "${var.prefix}-ssh"
  description = "for ${var.prefix}-vpc"

  vpc_id = "${aws_vpc.default.id}"

  # SSH
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

  # HTTP
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  # HTTP Proxy
  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  # HTTPS
  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  # HTTPS Proxy
  ingress {
    from_port = 8443
    to_port = 8443
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"
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
