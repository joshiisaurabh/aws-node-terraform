output "ec2_public_ip" {
  description = "Public IP of EC2 instance"
  value       = aws_instance.hello.public_ip
}

output "app_url" {
  description = "URL to access Node.js app in browser"
  value       = "http://${aws_instance.hello.public_ip}:3000"
}
