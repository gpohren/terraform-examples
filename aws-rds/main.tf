provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

# Instance database
resource "aws_db_instance" "database" {
  allocated_storage      = 20
  identifier             = "mysql-instance"
  engine                 = "mysql"
  engine_version         = "5.7.40"
  instance_class         = "db.t2.micro"
  db_name                = "mydb"
  username               = "admin"
  password               = "12qwaszx"
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.db_subnet.id
}
