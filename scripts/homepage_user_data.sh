#!/bin/bash
echo "<h1>Welcome to Homepage</h1>" > /var/www/html/index.html
apt install -y nginx
systemctl start nginx
systemctl enable nginx
echo "<h1>Home</h1>" > /usr/share/nginx/html/index.html
echo "<p>Instance A</p>" >> /usr/share/nginx/html/index.html
