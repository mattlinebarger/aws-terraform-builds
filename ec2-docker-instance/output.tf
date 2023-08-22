output "ec2_instance_id" {
    value = aws_instance.docker.id
}
output "ec2_instance_public_ip" {
    value = aws_instance.docker.public_ip
}
output "ec2_instance_public_dns" {
    value = aws_instance.docker.public_dns
}
output "ec2-user_password" {
    value = var.ec2-user_password
}