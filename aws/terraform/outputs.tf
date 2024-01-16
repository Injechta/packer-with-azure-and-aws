# Output the website URL using the public DNS of the Ubuntu instance
output "ubuntu_website_url" {
  value       = "http://${aws_instance.b3_gr3_ubuntu_instance.public_dns}"
  description = "URL to access the Ubuntu web server"
}

# Output the SSH command to connect to the Ubuntu instance
output "ubuntu_ssh_command" {
  value       = "ssh -i ${path.module}/ssh/b3_gr3_private_key.pem ubuntu@${aws_instance.b3_gr3_ubuntu_instance.public_dns}"
  description = "SSH command to connect to the Ubuntu instance"
}

# Output the website URL using the public DNS of the Debian instance
output "debian_website_url" {
  value       = "http://${aws_instance.b3_gr3_debian_instance.public_dns}"
  description = "URL to access the Debian web server"
}

# Output the SSH command to connect to the Debian instance
output "debian_ssh_command" {
  value       = "ssh -i ${path.module}/ssh/b3_gr3_private_key.pem admin@${aws_instance.b3_gr3_debian_instance.public_dns}"
  description = "SSH command to connect to the Debian instance"
}
