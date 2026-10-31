data "aws_caller_identity" "current" {}

output "whoami" {
  value = data.aws_caller_identity.current.arn
}

variable "my_ip" {
  description = "Public IP allowed to SSH in, in CIDR form"
  type        = string
}

data "aws_vpc" "default" {
  default = true
}

resource "aws_security_group" "test" {
  name        = "terraform-test"
  description = "Access to the Terraform test instance"
  vpc_id      = data.aws_vpc.default.id
}

resource "aws_vpc_security_group_ingress_rule" "ssh" {
  security_group_id = aws_security_group.test.id
  description       = "SSH from my IP"
  cidr_ipv4         = var.my_ip
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "all" {
  security_group_id = aws_security_group.test.id
  description       = "All outbound traffic"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_ingress_rule" "http" {
  security_group_id = aws_security_group.test.id
  description       = "HTTP from anywhere"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "https" {
  security_group_id = aws_security_group.test.id
  description       = "HTTPS from anywhere"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
}

resource "aws_key_pair" "test" {
  key_name   = "terraform-test"
  public_key = file(pathexpand("~/.ssh/terraform-test.pub"))
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023*-x86_64"]
  }
}

resource "aws_instance" "test" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = "t3.micro"
  key_name                    = aws_key_pair.test.key_name
  vpc_security_group_ids      = [aws_security_group.test.id]
  associate_public_ip_address = true

  root_block_device {
    volume_type = "gp3"
    volume_size = 8
    encrypted   = true

    tags = {
      Name = "terraform-test-root"
    }
  }

  tags = {
    Name = "terraform-test"
  }
}

output "public_ip" {
  value = aws_instance.test.public_ip
}

resource "aws_ebs_volume" "data" {
  availability_zone = aws_instance.test.availability_zone
  size              = 5
  type              = "gp3"
  encrypted         = true

  tags = {
    Name = "terraform-test-data"
  }
}

resource "aws_volume_attachment" "data" {
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.data.id
  instance_id = aws_instance.test.id
}