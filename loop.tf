//count loop=====>>>>>>>>>

/*terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.14.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "ap-south-1"
}

data "aws_vpc" "vpc" {
  default = true
}

data "aws_availability_zones" "available" {
  state = "available"
}

variable "private_subnet" {
  type    = list(string)
  default = ["172.31.16.0/24" , "172.31.17.0/24"] 
}

resource "aws_subnet" "private" {
  count             = length(var.private_subnet)
  vpc_id            = data.aws_vpc.vpc.id
  cidr_block        = var.private_subnet[count.index]   
  availability_zone = data.aws_availability_zones.available.names[count.index]
map_public_ip_on_launch = false


output "total-availability_zone" {
    value = data.aws_availability_zones.available
  
}/*
