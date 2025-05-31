#!/bin/bash
# User data script for images instance

# Wait for cloud-init to complete
/usr/bin/cloud-init status --wait

# Update system packages
apt-get update
apt-get upgrade -y

# Install nginx
apt-get install -y nginx

# Create directory structure
mkdir -p /var/www/html/images

# Create custom index.html for images path
cat > /var/www/html/images/index.html << 'EOT'
<!DOCTYPE html>
<html>
<head>
    <title>Image Gallery</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 0;
            background-color: #f0f8ff;
        }
        header {
            background-color: #2c3e50;
            color: white;
            padding: 20px;
            text-align: center;
        }
        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
        }
        .gallery {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
            grid-gap: 20px;
            margin-top: 20px;
        }
        .image-card {
            background-color: white;
            border-radius: 8px;
            overflow: hidden;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
            transition: transform 0.3s;
        }
        .image-card:hover {
            transform: translateY(-5px);
        }
        .image-placeholder {
            height: 200px;
            background-color: #ddd;
            display: flex;
            align-items: center;
            justify-content: center;
            color: #666;
            font-weight: bold;
        }
        .image-info {
            padding: 15px;
        }
        .image-info h3 {
            margin-top: 0;
            color: #2c3e50;
        }
        .image-info p {
            color: #7f8c8d;
            margin-bottom: 0;
        }
        .back-link {
            display: inline-block;
            margin-top: 20px;
            padding: 10px 20px;
            background-color: #3498db;
            color: white;
            text-decoration: none;
            border-radius: 4px;
            transition: background-color 0.3s;
        }
        .back-link:hover {
            background-color: #2980b9;
        }
    </style>
</head>
<body>
    <header>
        <h1>Image Gallery</h1>
        <p>This is Instance B serving the /images path</p>
    </header>
    <div class="container">
        <a href="/" class="back-link">Back to Homepage</a>
        <div class="gallery">
            <div class="image-card">
                <div class="image-placeholder">Image 1</div>
                <div class="image-info">
                    <h3>Nature Scene</h3>
                    <p>A beautiful landscape photograph.</p>
                </div>
            </div>
            <div class="image-card">
                <div class="image-placeholder">Image 2</div>
                <div class="image-info">
                    <h3>Urban Architecture</h3>
                    <p>Modern building design in the city.</p>
                </div>
            </div>
            <div class="image-card">
                <div class="image-placeholder">Image 3</div>
                <div class="image-info">
                    <h3>Wildlife</h3>
                    <p>Animals in their natural habitat.</p>
                </div>
            </div>
            <div class="image-card">
                <div class="image-placeholder">Image 4</div>
                <div class="image-info">
                    <h3>Abstract Art</h3>
                    <p>Creative expression through colors and shapes.</p>
                </div>
            </div>
            <div class="image-card">
                <div class="image-placeholder">Image 5</div>
                <div class="image-info">
                    <h3>Food Photography</h3>
                    <p>Delicious culinary creations.</p>
                </div>
            </div>
            <div class="image-card">
                <div class="image-placeholder">Image 6</div>
                <div class="image-info">
                    <h3>Portrait</h3>
                    <p>Capturing human expression and emotion.</p>
                </div>
            </div>
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

    location /images {
        alias /var/www/html/images;
        try_files $uri $uri/ =404;
    }
}
EOT

# Restart nginx to apply changes
systemctl restart nginx
