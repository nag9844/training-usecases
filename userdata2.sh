#!/bin/bash
yum update -y
yum install -y httpd
systemctl enable httpd
systemctl start httpd
mkdir -p /var/www/html/images
echo "Image Gallery - Instance 2" > /var/www/html/images/index.html