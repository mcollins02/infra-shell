data "aws_availability_zones" "all" {}

resource "aws_instance" "tlos" {
  count                  = "${var.ec2_count}"
  ami                    = "ami-033a8d58181b27f4a"
  instance_type          = "${var.instance_type}"
  iam_instance_profile   = "updateRoute53TLOS"
  key_name               = "${var.key_name}"
  vpc_security_group_ids = ["${aws_security_group.customerAccess.id}"]

  tags {
    Name = "${var.cluster_name}-TLOS"
  }
}

resource "aws_security_group" "customerAccess" {
    name = "${var.cluster_name}-Access"


    ingress {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["${var.customer_ip}"]
    }

    ingress {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["${var.customer_ip}"]
    }

    ingress {
      from_port   = -1
      to_port     = -1
      protocol    = "icmp"
      cidr_blocks = ["${var.customer_ip}"]
    }

    ingress {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }

    tags {
      Name = "${var.cluster_name}-customerAccess-SG"
    }
}

resource "aws_route53_record" "tlos" {
  zone_id = "Z22RDN2BH716NA"
  name = "${var.customer_dns}"
  type = "A"
  ttl  = 60
  records = ["${aws_instance.tlos.public_ip}"]
}
