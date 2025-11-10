variable "aws_region" {
  type        = string
  default     = "ap-south-1" # You can change this to your AWS region
  description = "AWS region where resources will be created"
}

variable "instance_type" {
  type        = string
  default     = "t3.micro"
  description = "EC2 instance type"
}

variable "ssh_key_name" {
  type        = string
  default     = ""
  description = "Optional SSH key pair name for EC2 access"
}
