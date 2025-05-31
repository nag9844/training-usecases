#!/bin/bash
apt install -y nginx
systemctl start nginx
systemctl enable nginx
mkdir -p /usr/share/nginx/html/register
echo "<h1>Register</h1>" > /usr/share/nginx/html/register/index.html
echo "<p>Instance C</p>" >> /usr/share/nginx/html/register/index.html
