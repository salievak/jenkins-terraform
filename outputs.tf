output "jenkins_instance_public_ip" {
  description = "Публічна IP-адреса Jenkins EC2 інстансу"
  value       = aws_instance.jenkins.public_ip
}

output "jenkins_elastic_ip" {
  description = "Еластична IP-адреса, прив'язана до інстансу"
  value       = aws_eip.jenkins.public_ip
}

output "jenkins_dns_record" {
  description = "Повне DNS ім'я для доступу до Jenkins"
  value       = aws_route53_record.jenkins.fqdn
}

output "jenkins_url" {
  description = "URL для доступу до Jenkins через Nginx"
  value       = "https://${aws_route53_record.jenkins.fqdn}"
}

output "secret_manager_arn" {
  description = "ARN секрету з паролем адміністратора Jenkins"
  value       = aws_secretsmanager_secret.jenkins_admin.arn
}

output "get_admin_password_command" {
  description = "Команда для отримання пароля адміністратора"
  value = "aws secretsmanager get-secret-value --secret-id ${aws_secretsmanager_secret.jenkins_admin.name} --query SecretString --output text"
}