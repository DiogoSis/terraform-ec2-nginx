output "instance_id" {
  description = "ID da instância EC2"
  value       = aws_instance.app.id
}

output "instance_public_ip" {
  description = "IP público da instância EC2"
  value       = aws_instance.app.public_ip
}

output "instance_public_dns" {
  description = "DNS público da instância EC2"
  value       = aws_instance.app.public_dns
}

output "nginx_url" {
  description = "URL do Nginx"
  value       = "http://${aws_instance.app.public_ip}"
}

output "rabbitmq_management_url" {
  description = "URL do RabbitMQ Management"
  value       = "http://${aws_instance.app.public_ip}:15672"
}

output "ssh_command" {
  description = "Comando para conectar via SSH"
  value       = "ssh -i ~/.ssh/id_rsa ubuntu@${aws_instance.app.public_ip}"
}