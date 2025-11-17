terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket  = "my-terraform-state-bucket-42805"
    key     = "aws-node-terraform/terraform.tfstate"
    region  = "ap-south-1"
    encrypt = true
  }
}

provider "aws" {
  region = var.aws_region
}

# --- Get default VPC and all subnets ---
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# --- Get latest Amazon Linux 2023 AMI ---
data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

# --- EC2 User data ---
locals {
  user_data = <<-EOT
    #!/bin/bash
    dnf -y update
    dnf -y install git nodejs
    cd /opt
    git clone https://github.com/joshiisaurabh/aws-node-terraform.git app
    cd app/node-app
    npm install
    nohup npm start &
  EOT
}

# --- EC2 instance ---
resource "aws_instance" "hello" {
  ami                         = data.aws_ami.al2023.id
  instance_type               = var.instance_type
  subnet_id                   = element(data.aws_subnets.default_subnets.ids, 0)
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
  associate_public_ip_address = true
  user_data                   = local.user_data
  key_name                    = var.ssh_key_name == "" ? null : var.ssh_key_name

  tags = {
    Name = "hello-node-ec2"
  }
}
