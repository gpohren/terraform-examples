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