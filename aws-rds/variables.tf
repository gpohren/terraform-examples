variable "aws_region" {
  description = "AWS Region"
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "AWS Profile"
  default     = "main"
}

variable "aws_key_path" {
  description = "Key path"
  default     = "../keys/aws_key.pub"
}