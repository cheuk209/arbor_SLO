terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "eu-west-1"
}


terraform {
  backend "s3" {
    bucket = "tf-state-cheuk"
    key    = "key/terraform.tfstate"
    region = "eu-west-1"
  }
}
