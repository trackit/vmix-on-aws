output "ec2_password" {
  description = "Password to access EC2"
  value       = rsadecrypt(aws_instance.vmix.password_data, tls_private_key.vmix-key.private_key_pem)
  sensitive   = true
}

output "vmix_server_name" {
  description = "EC2 DNS Name"
  value       = aws_instance.vmix.public_dns
}

output "private_key" {
  description = "EC2 Private Key File"
  value     = "Use the file vmix.pem"
}