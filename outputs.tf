output "vpc_id" {
  value = "${aws_vpc.default.id}"
}

output "zone_names" {
  value = [
    "${data.aws_availability_zones.available.names}"
  ]
}

output "public_subnet_ids" {
  value = [
    "${aws_subnet.public.*.id}"
  ]
}

output "private_subnet_ids" {
  value = [
    "${aws_subnet.private.*.id}"
  ]
}

output "security_group_ids" {
  value = [
    "${aws_security_group.self.id}",
    "${aws_security_group.ssh.id}",
    "${aws_security_group.web.id}",
  ]
}

output "security_group_self" {
  value = "${aws_security_group.self.id}"
}

output "security_group_ssh" {
  value = "${aws_security_group.ssh.id}"
}

output "security_group_web" {
  value = "${aws_security_group.web.id}"
}
