#!/bin/bash

# Update
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl gnupg software-properties-common

# Add official repository Jenkins
curl -fsSL https://pkg.jenkins.io/debian/jenkins.io-2023.key | sudo tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null

echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian binary/" | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null

# Update
sudo apt update

# Install Java
sudo apt install -y openjdk-17-jre

# Install Jenkins
sudo apt install -y jenkins

# Start and enable Jenkins
sudo systemctl enable --now jenkins

# Install
apt install nginx -y

# Start Nginx
systemctl start nginx

# Enable Nginx
systemctl enable nginx

#Proxy nginx
tee /etc/nginx/conf.d/jenkins.conf > /dev/null <<EOT
server {
        listen 80;
        server_name jenkins.ksalieva06.pp.ua;

    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }
}
EOT
systemctl restart nginx

# Install certbot

apt update && sudo apt upgrade -y

apt install -y certbot python3-certbot-nginx

certbot --nginx -d jenkins.ksalieva06.pp.ua --non-interactive --agree-tos --email katesalieva4685@gmail.com