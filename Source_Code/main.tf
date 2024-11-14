terraform {
  backend "s3" {
    bucket = "aws-tf-backend-vv-bucket"
    key    = "terraform/dev/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
}

provider "aws" {
  alias  = "west"
  region = "us-west-2"
}