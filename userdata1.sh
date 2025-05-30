#!/bin/bash
yum update -y
yum install -y httpd
systemctl enable httpd
systemctl start httpd
echo "Welcome to Instance 1 - Root Page" > /var/www/html/index.html