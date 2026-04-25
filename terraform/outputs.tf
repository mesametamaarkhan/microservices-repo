output "instance_public_ip" {
  description = "Public IP of the EC2 instance."
  value       = aws_instance.app.public_ip
}

output "instance_public_dns" {
  description = "Public DNS of the EC2 instance."
  value       = aws_instance.app.public_dns
}

output "ssh_command" {
  description = "SSH command template for connecting to the server."
  value       = "ssh -i <path-to-key.pem> ubuntu@${aws_instance.app.public_ip}"
}
