# --- Target Group ---
resource "aws_lb_target_group" "hello_tg" {
  name        = "hello-tg"
  port        = 3000
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = data.aws_vpc.default.id

  health_check {
    path                = "/"
    port                = "3000"
    protocol            = "HTTP"
    unhealthy_threshold = 3
    healthy_threshold   = 2
  }
}

# --- ALB ---
resource "aws_lb" "hello_alb" {
  name               = "hello-alb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = data.aws_subnets.default_subnets.ids
}

# --- Listener on port 80 ---
resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.hello_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.hello_tg.arn
  }
}

# --- Attach EC2 to target group ---
resource "aws_lb_target_group_attachment" "hello_attach" {
  target_group_arn = aws_lb_target_group.hello_tg.arn
  target_id        = aws_instance.hello.id
  port             = 3000
}
