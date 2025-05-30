#!/bin/bash
yum update -y
yum install -y httpd
systemctl enable httpd
systemctl start httpd
mkdir -p /var/www/html/register
echo "Register Here - Instance 3" > /var/www/html/register/index.html