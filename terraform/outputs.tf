output "instance_public_ip" {
  value = aws_instance.app_server.public_ip
}

output "instance_id" {
  value = aws_instance.app_server.id
}

output "elastic_ip" {
  value = data.aws_eip.existing_eip.public_ip
}
