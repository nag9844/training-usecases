#!/bin/bash
# User data script for homepage instance

# Wait for cloud-init to complete
/usr/bin/cloud-init status --wait

# Update system packages
apt-get update
apt-get upgrade -y

# Install nginx
apt-get install -y nginx

# Create custom index.html for homepage
cat > /var/www/html/index.html << 'EOT'
<!DOCTYPE html>
<html>
<head>
    <title>Homepage</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 0;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            background-color: #f0f8ff;
        }
        .container {
            text-align: center;
            padding: 40px;
            background-color: white;
            border-radius: 8px;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
            max-width: 800px;
        }
        h1 {
            color: #2c3e50;
            margin-bottom: 20px;
        }
        p {
            color: #34495e;
            line-height: 1.6;
            margin-bottom: 20px;
        }
        .links {
            display: flex;
            justify-content: center;
            gap: 20px;
            margin-top: 30px;
        }
        .link-button {
            display: inline-block;
            padding: 10px 20px;
            background-color: #3498db;
            color: white;
            text-decoration: none;
            border-radius: 4px;
            transition: background-color 0.3s;
        }
        .link-button:hover {
            background-color: #2980b9;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Welcome to Our Homepage</h1>
        <p>This is Instance A serving the root path.</p>
        <p>Our application uses AWS Application Load Balancer with path-based routing to direct requests to different EC2 instances based on the URL path.</p>
        <div class="links">
            <a href="/images" class="link-button">View Images</a>
            <a href="/register" class="link-button">Register</a>
        </div>
    </div>
</body>
</html>
EOT

# Configure nginx
cat > /etc/nginx/sites-available/default << 'EOT'
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    
    root /var/www/html;
    index index.html;
    
    server_name _;
    
    location / {
        try_files $uri $uri/ =404;
    }
}
EOT

# Restart nginx to apply changes
systemctl restart nginx
