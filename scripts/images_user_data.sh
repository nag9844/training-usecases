#!/bin/bash
# User data script for images instance

# Update system packages
yum update -y

# Install and start nginx
amazon-linux-extras install -y nginx1
systemctl enable nginx
systemctl start nginx

# Create directory structure
mkdir -p /usr/share/nginx/html/images

# Create custom index.html for images path
cat > /usr/share/nginx/html/images/index.html << 'EOT'
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
cat > /etc/nginx/conf.d/default.conf << 'EOT'
server {
    listen 80;
    server_name _;
    
    location / {
        root /usr/share/nginx/html;
        index index.html;
    }

    location /images {
        alias /usr/share/nginx/html/images;
        index index.html;
    }
}
EOT

# Restart nginx to apply changes
systemctl restart nginx