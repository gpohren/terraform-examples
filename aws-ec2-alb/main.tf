provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

# EC2 instance 1
resource "aws_instance" "web_01" {
  ami             = var.ami
  instance_type   = var.instance_micro
  subnet_id       = aws_subnet.public_1a.id
  key_name        = aws_key_pair.aws_key.key_name
  security_groups = [aws_security_group.base_security.id]
  user_data       = file("user-data/web_01.sh")
  tags = {
    Name = "web_01"
  }
}

# EC2 instance 2
resource "aws_instance" "web_02" {
  ami             = var.ami
  instance_type   = var.instance_micro
  subnet_id       = aws_subnet.public_1b.id
  key_name        = aws_key_pair.aws_key.key_name
  security_groups = [aws_security_group.base_security.id]
  user_data       = file("user-data/web_02.sh")
  tags = {
    Name = "web_02"
  }
}

# Load Balancer
resource "aws_lb" "webservers" {
  name               = "webservers"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.base_security.id]
  subnets            = [aws_subnet.public_1a.id, aws_subnet.public_1b.id]
}

# Target Groups
resource "aws_lb_target_group" "front_end" {
  name     = "webservers"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id
}

# Attach Target Groups
resource "aws_lb_target_group_attachment" "web_01" {
  target_group_arn = aws_lb_target_group.front_end.arn
  target_id        = aws_instance.web_01.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "web_02" {
  target_group_arn = aws_lb_target_group.front_end.arn
  target_id        = aws_instance.web_02.id
  port             = 80
}

# Listener
resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.webservers.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.front_end.arn
  }
}