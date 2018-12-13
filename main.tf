provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region = "${var.region}"
}

resource "aws_eip" "nat" {
  count = "1"
  vpc = true
}

resource "aws_eip" "bastion" {
  count = "1"
  vpc = true
  instance = "${aws_instance.bastion.id}"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "test-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  reuse_nat_ips       = true                      # <= Skip creation of EIPs for the NAT Gateways
  external_nat_ip_ids = ["${aws_eip.nat.*.id}"]   # <= IPs specified here as input to the module

  enable_dns_hostnames = true
  enable_dns_support = true
  instance_tenancy     = "default"
  
  map_public_ip_on_launch = true # <= aws_subnet

  tags = {
    Terraform = "true"
    Environment = "dev"
    Name = "test-vpc"
  }
}


# resource "aws_network_acl" "acl" {
#   vpc_id = "${module.vpc.vpc_id}"

#   tags = {
#     Terraform = "true"
#     Environment = "dev"
#     Name = "test"
#   }
# }

# resource "aws_network_acl_rule" "ssh" {
#   network_acl_id = "${aws_network_acl.acl.id}"
#   rule_number    = 200
#   egress         = false
#   protocol       = "tcp"
#   rule_action    = "allow"
#   cidr_block     = "0.0.0.0/0"
#   from_port      = 22
#   to_port        = 22
# }



module "cassandra_security_group" {
  source = "terraform-aws-modules/security-group/aws//modules/cassandra"
  name = "cassandra"
  vpc_id = "${module.vpc.vpc_id}"
  ingress_cidr_blocks = ["0.0.0.0/0"] # <= Specify ingress port for inbound rules
}

resource "aws_security_group" "allow_ssh_for_bastion" {
  name        = "allow_ssh_for_bastion"
  vpc_id = "${module.vpc.vpc_id}"
  
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # <= Change to your workstation

  }

  egress {
    protocol = -1
    from_port   = 0 
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"] # <= Change to your workstation
  }

  tags = {
    Terraform = "true"
    Environment = "dev"
    Name = "bastion-ssh"
  }
}

resource "aws_security_group" "allow_ssh_for_cassandra" {
  name   = "allow_ssh_for_cassandra"
  vpc_id = "${module.vpc.vpc_id}"
  
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    security_groups = ["${aws_security_group.allow_ssh_for_bastion.id}"]
  }

  tags = {
    Terraform = "true"
    Environment = "dev"
    Name = "private-ssh"
  }
}
