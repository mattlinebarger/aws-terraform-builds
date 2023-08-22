terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.region
  profile = var.profile_name
}

# Create EC2 Instance for Docker
resource "aws_instance" "docker" {
  ami = var.ami
  instance_type = var.instance_type
  key_name = var.instance_key
  subnet_id = var.subnet
  security_groups = var.security_groups
  associate_public_ip_address = true
  tags = var.instance_tags
  volume_tags = var.instance_tags
  user_data = <<EOF
#!/bin/bash
sudo dnf update -y
sudo curl -o /home/ec2-user/.bash_profile https://gist.githubusercontent.com/mattlinebarger/aaaf2f88c9e9a1ca817771db66a06bb2/raw/4d13ae05f1f63026ec608bdcb4f3b198f886b81e/.bash_profile
sudo dnf install -y git
sudo dnf install -y docker
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ec2-user
newgrp docker
sudo curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo curl -o /etc/ssh/sshd_config https://gist.githubusercontent.com/mattlinebarger/ca6f955eec4a8c454d67cece0e2d5cd4/raw/f2b40e9e5f68401440bcace780cf90f31a62a761/sshd_config
sudo systemctl restart sshd
echo ec2-user:${var.ec2-user_password} | sudo chpasswd
sudo dnf install -y vsftpd
sudo curl -o /etc/vsftpd/vsftpd.conf https://gist.githubusercontent.com/mattlinebarger/3086c3f4c4a5de7ba96c81b834166736/raw/2494083de2e0fa21ccc67c97b12ddaa2235f5f38/vsftpd.conf
THEIP=$(curl http://checkip.amazonaws.com 2>/dev/null)
echo $THEIP >> /etc/vsftpd/vsftpd.conf
sudo systemctl restart vsftpd
sudo systemctl enable vsftpd
EOF
}