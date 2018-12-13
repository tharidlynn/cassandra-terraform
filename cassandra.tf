resource "aws_instance" "bastion" {
  ami = "${var.ami}"
  instance_type = "${var.bastion_instance_type}"
  subnet_id = "${module.vpc.public_subnets[0]}"
  vpc_security_group_ids = ["${aws_security_group.allow_ssh_for_bastion.id}"]
  key_name = "test_key"
  associate_public_ip_address = true
  tags = {
    Terraform = "true"
    Environment = "dev"
    Name = "bastion"
  }
}

resource "aws_instance" "cassandra_1" {
  instance_type = "${var.node_instance_type}"
  ami = "${var.ami}"
  subnet_id = "${module.vpc.private_subnets[0]}"
  private_ip = "10.0.1.22"
  key_name = "test_key"
  vpc_security_group_ids = ["${module.cassandra_security_group.this_security_group_id}", "${aws_security_group.allow_ssh_for_cassandra.id}"]

  timeouts {
    create = "60m"
    delete = "2h"
  }

  provisioner "file" {
    source = "${path.module}/provisioning/setup-cassandra.sh"
    destination = "/home/ubuntu/setup-cassandra.sh"
    connection {
      type = "ssh"
      host = "${self.private_ip}"
      user = "ubuntu"
      private_key = "${file(var.ssh_key_path)}"

      bastion_host = "${aws_instance.bastion.public_ip}"
      bastion_user = "ubuntu"
      bastion_private_key = "${file(var.ssh_key_path)}"
    }
  }

  provisioner "remote-exec" {
    inline = [
      "bash /home/ubuntu/setup-cassandra.sh 1"
    ]
    connection {
      type = "ssh"
      host = "${self.private_ip}"
      user = "ubuntu"
      private_key = "${file(var.ssh_key_path)}"

      bastion_host = "${aws_instance.bastion.public_ip}"
      bastion_user = "ubuntu"
      bastion_private_key = "${file(var.ssh_key_path)}"
    }
  }

  tags {
    Terraform = "true"
    Environment = "dev"
    Name = "cassandra_1"
  }
}

resource "aws_instance" "cassandra_2" {
  instance_type = "${var.node_instance_type}"
  ami = "${var.ami}"
  subnet_id = "${module.vpc.private_subnets[1]}"
  private_ip = "10.0.2.22"
  key_name = "test_key"
  vpc_security_group_ids = ["${module.cassandra_security_group.this_security_group_id}", "${aws_security_group.allow_ssh_for_cassandra.id}"]

  timeouts {
    create = "60m"
    delete = "2h"
  }

  provisioner "file" {
    source = "${path.module}/provisioning/setup-cassandra.sh"
    destination = "/home/ubuntu/setup-cassandra.sh"
    connection {
      type = "ssh"
      host = "${self.private_ip}"
      user = "ubuntu"
      private_key = "${file(var.ssh_key_path)}"

      bastion_host = "${aws_instance.bastion.public_ip}"
      bastion_user = "ubuntu"
      bastion_private_key = "${file(var.ssh_key_path)}"
    }
  }

  provisioner "remote-exec" {
    inline = [
      "bash /home/ubuntu/setup-cassandra.sh 2"
    ]
    connection {
      type = "ssh"
      host = "${self.private_ip}"
      user = "ubuntu"
      private_key = "${file(var.ssh_key_path)}"

      bastion_host = "${aws_instance.bastion.public_ip}"
      bastion_user = "ubuntu"
      bastion_private_key = "${file(var.ssh_key_path)}"
    }
  }

  tags {
    Terraform = "true"
    Environment = "dev"
    Name = "cassandra_2"
  }
}

resource "aws_instance" "cassandra_3" {
  instance_type = "${var.node_instance_type}"
  ami = "${var.ami}"
  subnet_id = "${module.vpc.private_subnets[2]}"
  private_ip = "10.0.3.22"
  key_name = "test_key"
  vpc_security_group_ids = ["${module.cassandra_security_group.this_security_group_id}", "${aws_security_group.allow_ssh_for_cassandra.id}"]

  timeouts {
    create = "60m"
    delete = "2h"
  }

  provisioner "file" {
    source = "${path.module}/provisioning/setup-cassandra.sh"
    destination = "/home/ubuntu/setup-cassandra.sh"
    connection {
      type = "ssh"
      host = "${self.private_ip}"
      user = "ubuntu"
      private_key = "${file(var.ssh_key_path)}"

      bastion_host = "${aws_instance.bastion.public_ip}"
      bastion_user = "ubuntu"
      bastion_private_key = "${file(var.ssh_key_path)}"
    }
  }

  provisioner "remote-exec" {
    inline = [
      "bash /home/ubuntu/setup-cassandra.sh 3"
    ]
    connection {
      type = "ssh"
      host = "${self.private_ip}"
      user = "ubuntu"
      private_key = "${file(var.ssh_key_path)}"

      bastion_host = "${aws_instance.bastion.public_ip}"
      bastion_user = "ubuntu"
      bastion_private_key = "${file(var.ssh_key_path)}"
    }
  }


  tags {
    Terraform = "true"
    Environment = "dev"
    Name = "cassandra_3"
  }
}

resource "aws_ebs_volume" "cassandra_1" {
  availability_zone = "ap-southeast-1a"
  size = 100
  type = "gp2"

  tags {
    Name = "cassandra_1"
  }
}

resource "aws_ebs_volume" "cassandra_2" {
  availability_zone = "ap-southeast-1b"
  size = 100
  type = "gp2"

  tags {
    Name = "cassandra_2"
  }
}

resource "aws_ebs_volume" "cassandra_3" {
  availability_zone = "ap-southeast-1c"
  size = 100
  type = "gp2"
  
  tags {
    Name = "cassandra_3"
  }
}

resource "aws_volume_attachment" "cassandra_1_ebs_att" {
  device_name = "/dev/sdh"
  volume_id = "${aws_ebs_volume.cassandra_1.id}"
  instance_id = "${aws_instance.cassandra_1.id}"
}

resource "aws_volume_attachment" "cassandra_2_ebs_att" {
  device_name = "/dev/sdh"
  volume_id = "${aws_ebs_volume.cassandra_2.id}"
  instance_id = "${aws_instance.cassandra_2.id}"
}

resource "aws_volume_attachment" "cassandra_3_ebs_att" {
  device_name = "/dev/sdh"
  volume_id = "${aws_ebs_volume.cassandra_3.id}"
  instance_id = "${aws_instance.cassandra_3.id}"
}