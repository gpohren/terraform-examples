# Thanks to https://blog.gruntwork.io/how-to-manage-terraform-state-28f5697e68fa

terraform {
  backend "s3" {
    bucket         = "terraform-state-files-2022"
    key            = "global/s3/terraform.tfstate"
    region         = "us-east-1"
    profile        = "main"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
