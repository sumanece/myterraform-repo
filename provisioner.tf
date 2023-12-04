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

resource "aws_security_group" "sg1" {
  name        = "vpc_file"
  description = "Allow TLS inbound/outbound traffic"
  vpc_id      = data.aws_vpc.vpc.id

  ingress {
    description = "TLS from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

 ingress {
    description = "TLS from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "vpc-file"
  }
}

/*data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-20230517"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}*/

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = file("ec2-key.pub")
}

resource "aws_instance" "main" {
  ami             = "ami-04341a215040f91bb"
  instance_type   = local.size
  security_groups = [aws_security_group.sg1.name]
  key_name        = aws_key_pair.deployer.key_name
  user_data       = local.user_data
  provisioner "remote-exec" {
    inline = [ 
      "echo we had trained for devops >> file3",
      "hostname"
      ]
   connection {
    host        = self.public_dns
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("ec2-key")
   } 
  }
  provisioner "local-exec" {
    command = "echo this is private ip-${self.private_ip} >> ec2-output.txt"
  }

  /*provisioner "file" {
    source      = "ec2-key"
    destination = "my_private_key.pem"
  connection {
    host        = self.public_dns
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("ec2-key")
  }
 }*/
}

output "vm-public-ip" {
  value = aws_instance.main.public_dns

}

locals {
  size      = "t2.micro"
  user_data = <<-EOF
  #!/bin/bash
  sudo apt update -y
  sudo apt install apache2 -y
  sudo systemctl enable apache2
  sudo systemctl start apache2
  git clone https://github.com/mevijays/training-terraform
  sudo mv training-terraform /var/www/html/
  sudo echo '<hello dada>' >> /var/www/html/index.html
  EOF
}