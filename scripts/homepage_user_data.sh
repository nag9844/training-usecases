#!/bin/bash
# User data script for homepage instance

# Update system packages
yum update -y

# Install and start nginx
amazon-linux-extras install -y nginx1
systemctl enable nginx
systemctl start nginx

# Create custom index.html for homepage
cat > /usr/share/nginx/html/index.html << 'EOT'
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
cat > /etc/nginx/conf.d/default.conf << 'EOT'
server {
    listen 80;
    server_name _;
    
    location / {
        root /usr/share/nginx/html;
        index index.html;
    }
}
EOT

# Restart nginx to apply changes
systemctl restart nginx