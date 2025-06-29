# Output values to display after deployment
output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.lamp_server.id
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_eip.lamp_eip.public_ip
}

output "instance_public_dns" {
  description = "Public DNS name of the EC2 instance"
  value       = aws_instance.lamp_server.public_dns
}

output "website_url" {
  description = "URL to access the website"
  value       = "http://${aws_eip.lamp_eip.public_ip}"
}

output "php_info_url" {
  description = "URL to access PHP info page"
  value       = "http://${aws_eip.lamp_eip.public_ip}/info.php"
}

output "ssh_command" {
  description = "SSH command to connect to the instance"
  value       = "ssh -i ~/.ssh/id_rsa ec2-user@${aws_eip.lamp_eip.public_ip}"
}

output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.lamp_sg.id
}
