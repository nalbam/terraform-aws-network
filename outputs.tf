output "vpc_id" {
  value = "${aws_vpc.default.id}"
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
    "${aws_security_group.ssh.id}",
    "${aws_security_group.web.id}"
  ]
}
