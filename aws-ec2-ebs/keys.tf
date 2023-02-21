resource "aws_key_pair" "aws_key" {
  key_name   = "aws_key"
  public_key = file(var.aws_key_path)
}