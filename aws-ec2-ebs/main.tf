provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

# Instance EC2
resource "aws_instance" "ec2" {
  ami                         = var.ami
  instance_type               = var.instance_micro
  subnet_id                   = aws_subnet.public_1a.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.base_security.id]
  key_name                    = aws_key_pair.aws_key.key_name
  tags = {
    Name = "ec2"
  }
}

# EBS volume
resource "aws_ebs_volume" "ebs_volume" {
  availability_zone = "us-east-1a"
  size              = 40
  type              = "gp2"

  tags = {
    Name = "ebs_volume"
  }
}

# EBS volume attachment
resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.ebs_volume.id
  instance_id = aws_instance.ec2.id
}
