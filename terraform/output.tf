output "vmix_server_name" {
  description = "EC2 DNS Name"
  value       = aws_instance.vmix.public_dns
}

output "vmix_instance_id" {
  description = "EC2 Instance ID"
  value       = aws_instance.vmix.id
}

output "vmix_instance_username" {
  description = "EC2 Instance username"
  value       = "Administrator"
}

output "private_key" {
  description = "EC2 Private Key File"
  value       = "Use the file vmix.pem"
}

output "medialive_api" {
  value = module.medialive_api
}

# output "media_live_api_gateway" {
#   description = "API GW Endpoint to control Media Live"
#   value       = "${aws_api_gateway_rest_api.api.id}.execute-api.${var.aws_region}.amazonaws.com/dev"
# }

# output "media_convert_endpoint" {
#   description = "Media Convert Endpoint "
#   value       = var.media_convert_endpoint
# }