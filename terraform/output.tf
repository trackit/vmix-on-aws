output "vmix_server_name" {
  description = "EC2 DNS Name"
  value       = aws_instance.vmix.public_dns
}

output "vmix_instance_id" {
  description = "EC2 DNS Name"
  value       = aws_instance.vmix.id
}

output "private_key" {
  description = "EC2 Private Key File"
  value     = "Use the file vmix.pem"
}