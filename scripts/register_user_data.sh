#!/bin/bash
# User data script for register instance

# Update system packages
yum update -y

# Install and start nginx
amazon-linux-extras install -y nginx1
systemctl enable nginx
systemctl start nginx

# Create directory structure
mkdir -p /usr/share/nginx/html/register

# Create custom index.html for register path
cat > /usr/share/nginx/html/register/index.html << 'EOT'
<!DOCTYPE html>
<html>
<head>
    <title>Registration Page</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 0;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            background-color: #f0f8ff;
        }
        .container {
            background-color: white;
            border-radius: 8px;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
            overflow: hidden;
            width: 100%;
            max-width: 500px;
        }
        .header {
            background-color: #2c3e50;
            color: white;
            padding: 20px;
            text-align: center;
        }
        .form-container {
            padding: 30px;
        }
        .form-group {
            margin-bottom: 20px;
        }
        label {
            display: block;
            margin-bottom: 8px;
            font-weight: bold;
            color: #2c3e50;
        }
        input[type="text"],
        input[type="email"],
        input[type="password"] {
            width: 100%;
            padding: 10px;
            border: 1px solid #ddd;
            border-radius: 4px;
            box-sizing: border-box;
        }
        .buttons {
            display: flex;
            justify-content: space-between;
            margin-top: 30px;
        }
        button {
            padding: 12px 24px;
            border: none;
            border-radius: 4px;
            font-weight: bold;
            cursor: pointer;
        }
        button.register {
            background-color: #27ae60;
            color: white;
        }
        button.register:hover {
            background-color: #219653;
        }
        .back-link {
            display: inline-block;
            padding: 12px 24px;
            background-color: #3498db;
            color: white;
            text-decoration: none;
            border-radius: 4px;
        }
        .back-link:hover {
            background-color: #2980b9;
        }
        .server-info {
            margin-top: 30px;
            padding: 15px;
            background-color: #f8f9fa;
            border-radius: 4px;
            font-size: 0.9em;
            color: #666;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>Register an Account</h1>
            <p>This is Instance C serving the /register path</p>
        </div>
        <div class="form-container">
            <div class="form-group">
                <label for="fullname">Full Name</label>
                <input type="text" id="fullname" name="fullname" placeholder="Enter your full name">
            </div>
            <div class="form-group">
                <label for="email">Email</label>
                <input type="email" id="email" name="email" placeholder="Enter your email address">
            </div>
            <div class="form-group">
                <label for="password">Password</label>
                <input type="password" id="password" name="password" placeholder="Create a password">
            </div>
            <div class="form-group">
                <label for="confirm-password">Confirm Password</label>
                <input type="password" id="confirm-password" name="confirm-password" placeholder="Confirm your password">
            </div>
            <div class="buttons">
                <a href="/" class="back-link">Back to Home</a>
                <button class="register">Register</button>
            </div>
            <div class="server-info">
                <p><strong>Note:</strong> This is a demonstration form. No data will actually be submitted.</p>
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

    location /register {
        alias /usr/share/nginx/html/register;
        index index.html;
    }
}
EOT

# Restart nginx to apply changes
systemctl restart nginx