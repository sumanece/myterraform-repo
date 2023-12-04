
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.14.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "ap-northeast-2"
}

data "aws_vpc" "vpc" {
  default = true
}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_subnets" "newsub" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }
}

variable "insta" {
  default = "3"
}



resource "aws_instance" "myvm" {
  count = var.insta
  ami           = "ami-0e581dc33f688a5df"
  instance_type = "t2.micro"
  subnet_id     = data.aws_subnets.newsub.id
  tags = {
    Name = "myvm-${count.index + 1 }"
  }
}
