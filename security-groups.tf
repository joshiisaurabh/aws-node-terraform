# --- ALB Security Group (public listener) ---
resource "aws_security_group" "alb_sg" {
  name        = "hello-alb-sg"
  description = "Allow HTTP traffic from internet"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "HTTP from internet"
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
}

# --- EC2 Security Group (private app) ---
resource "aws_security_group" "ec2_sg" {
  name        = "hello-node-sg"
  description = "Allow ALB to access Node.js on port 3000"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description      = "Allow ALB to connect to app"
    from_port        = 3000
    to_port          = 3000
    protocol         = "tcp"
    security_groups  = [aws_security_group.alb_sg.id]
  }

  ingress {
    description = "SSH from anywhere (change later)"
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
}
