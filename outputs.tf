# Outputs

output "ec2_instance_public_dns" {
  value = aws_instance.node.public_dns
}

output "ec2_instance_public_ip" {
  value = aws_instance.node.public_ip
}

output "jenkins_URL" {
  value = "http://${aws_instance.node.public_ip}:${var.jenkins_default_port}"
}
