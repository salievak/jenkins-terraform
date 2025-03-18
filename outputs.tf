output "jenkins_instance_public_ip" {
  description = "Public IP address of the Jenkins EC2 instance"
  value       = aws_instance.jenkins.public_ip
}

output "jenkins_elastic_ip" {
  description = "Elastic IP address bound to an instance"
  value       = aws_eip.jenkins.public_ip
}

output "jenkins_dns_record" {
  description = "Full DNS name to access Jenkins"
  value       = aws_route53_record.jenkins.fqdn
}

output "jenkins_url" {
  description = "URL to access Jenkins via Nginx"
  value       = "https://${aws_route53_record.jenkins.fqdn}"
}

output "secret_manager_arn" {
  description = "ARN of the secret with Jenkins administrator password"
  value       = aws_secretsmanager_secret.jenkins_admin.arn
}

output "get_admin_password_command" {
  description = "Command to get the administrator password"
  value = "aws secretsmanager get-secret-value --secret-id ${aws_secretsmanager_secret.jenkins_admin.name} --query SecretString --output text"
}
