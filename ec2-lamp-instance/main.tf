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
sudo dnf install -y httpd wget php-fpm php-mysqli php-json php php-devel
sudo dnf install -y mariadb105-server
sudo systemctl start httpd
sudo systemctl enable httpd
sudo usermod -a -G apache ec2-user
sudo chown -R ec2-user:apache /var/www
sudo chmod 2775 /var/www && find /var/www -type d -exec sudo chmod 2775 {} \;
find /var/www -type f -exec sudo chmod 0664 {} \;
echo "<?php phpinfo(); ?>" > /var/www/html/phpinfo.php
sudo systemctl start mariadb
sudo systemctl enable mariadb
mysqladmin -u root password "${var.mariadb_password}"
mysql -u root -p"${var.mariadb_password}" -e "UPDATE mysql.user SET Password=PASSWORD('${var.mariadb_password}') WHERE User='root'"
mysql -u root -p"${var.mariadb_password}" -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1')"
mysql -u root -p"${var.mariadb_password}" -e "DELETE FROM mysql.user WHERE User=''"
mysql -u root -p"${var.mariadb_password}" -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\_%'"
mysql -u root -p"${var.mariadb_password}" -e "FLUSH PRIVILEGES"
sudo dnf install -y php-mbstring php-xml
sudo systemctl restart httpd
sudo systemctl restart php-fpm
cd /var/www/html
wget https://www.phpmyadmin.net/downloads/phpMyAdmin-latest-all-languages.tar.gz
mkdir phpMyAdmin && tar -xvzf phpMyAdmin-latest-all-languages.tar.gz -C phpMyAdmin --strip-components 1
rm phpMyAdmin-latest-all-languages.tar.gz
sudo dnf install -y git
sudo curl -o /etc/ssh/sshd_config https://gist.githubusercontent.com/mattlinebarger/ca6f955eec4a8c454d67cece0e2d5cd4/raw/f2b40e9e5f68401440bcace780cf90f31a62a761/sshd_config
sudo systemctl restart sshd
echo ec2-user:${var.ec2-user_password} | sudo chpasswd
sudo dnf install -y vsftpd
sudo curl -o /etc/vsftpd/vsftpd.conf https://gist.githubusercontent.com/mattlinebarger/3086c3f4c4a5de7ba96c81b834166736/raw/56fe095199cfcea834a57b794c07d95dcf9af6c1/vsftpd.conf
THEIP=$(curl http://checkip.amazonaws.com 2>/dev/null)
sudo echo $THEIP >> /etc/vsftpd/vsftpd.conf
sudo systemctl restart vsftpd
sudo systemctl enable vsftpd
EOF
}