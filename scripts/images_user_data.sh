#!/bin/bash
apt install -y nginx
systemctl start nginx
systemctl enable nginx
mkdir -p /usr/share/nginx/html/images
echo "<h1>Image</h1>" > /usr/share/nginx/html/images/index.html
echo "<p>Instance B</p>" >> /usr/share/nginx/html/images/index.html
