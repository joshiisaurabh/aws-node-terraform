terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# --- Get default VPC and subnet info ---
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default_public_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

locals {
  subnet_id = element(data.aws_subnets.default_public_subnets.ids, 0)
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

# --- Security group for app (port 3000) and SSH ---
resource "aws_security_group" "hello_sg" {
  name        = "hello-node-sg"
  description = "Allow port 3000 and SSH"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "Allow Node.js app access"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow SSH access"
    from_port   = 22
    to_port     = 22
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
    Name = "hello-node-sg"
  }
}

# --- EC2 instance + inline user_data script ---
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

resource "aws_instance" "hello" {
  ami                         = data.aws_ami.al2023.id
  instance_type               = var.instance_type
  subnet_id                   = local.subnet_id
  vpc_security_group_ids      = [aws_security_group.hello_sg.id]
  associate_public_ip_address = true
  user_data                   = local.user_data
  key_name                    = var.ssh_key_name == "" ? null : var.ssh_key_name

  tags = {
    Name = "hello-node-ec2"
  }
}
