terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.21.0"
    }
  }
}

provider "aws" {
  region = "us-west-2"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.2"

  name = var.vpc_name
  cidr = var.vpc_cidr

  azs             = var.vpc_azs
  private_subnets = var.vpc_private_subnets
  public_subnets  = var.vpc_public_subnets

  enable_nat_gateway = var.vpc_enable_nat_gateway

  tags = var.vpc_tags
}

module "key_pair" {
  source = "terraform-aws-modules/key-pair/aws"

  key_name           = "deployer-one"
  create_private_key = true
}

resource "tls_private_key" "this" {
  algorithm = "RSA"
}

module "key_pair_external" {
  source = "terraform-aws-modules/key-pair/aws"

  key_name   = "deployer-two"
  public_key = trimspace(tls_private_key.this.public_key_openssh)
}

module "ec2_instances" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "5.5.0"

  count = 2
  name  = "my-ec2-cluster-${count.index}"

  ami                    = "ami-0c5204531f799e0c6"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [module.vpc.default_security_group_id]
  subnet_id              = module.vpc.public_subnets[0]
  key_name = "my-pub"
  associate_public_ip_address = "true"


  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}



