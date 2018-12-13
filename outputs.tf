output "bastion_public_ip" {
  value = "${aws_instance.bastion.public_ip}"
}

output "cassandra_1" {
    value = "${aws_instance.cassandra_1.private_ip}"
}

output "cassandra_2" {
  value = "${aws_instance.cassandra_2.private_ip}"
}

output "cassandra_3" {
  value = "${aws_instance.cassandra_3.private_ip}"
}

