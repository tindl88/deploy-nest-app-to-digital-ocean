#!/bin/bash

# Install Docker compose
sudo curl -L "https://github.com/docker/compose/releases/download/v2.29.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

# Define the folder
mkdir ~/nginx-proxy-manager && cd ~/nginx-proxy-manager

# Define the filename
filename="docker-compose.yml"

# Create the Docker Compose file
cat << EOF > $filename
version: '3.8'
services:
  app:
    image: 'jc21/nginx-proxy-manager:latest'
    restart: unless-stopped
    ports:
      - '80:80'
      - '81:81'
      - '443:443'
    volumes:
      - ./data:/data
      - ./letsencrypt:/etc/letsencrypt
EOF

echo "Docker Compose file '$filename' has been created."

# Optionally, display the contents of the file
echo "Contents of $filename:"
cat $filename

echo "Nginx Proxy Manager is now running."

# Open port 80 (HTTP)
ufw allow 80/tcp

# Open port 443 (HTTPS)
ufw allow 443/tcp

# Open port 81
ufw allow 81/tcp

# Fix port 22 issue connect on github action
ufw allow 22/tcp

# Reload UFW to apply changes
ufw reload

# Display the status of UFW
ufw status

echo "Ports 80, 81, and 443 have been opened."

# Register domain

# Edit DNS -> Create A Record with * point to your ip server

# https://dnschecker.org/ Check if domain name, subdomain is point to ip server
