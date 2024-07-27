#!/bin/bash

apt-get install -y docker.io

# Check if Docker Compose is already installed
if ! command -v docker-compose &> /dev/null
then
    echo "Docker Compose not found, installing..."
    curl -L "https://github.com/docker/compose/releases/download/v2.29.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
else
    echo "Docker Compose is already installed."
fi

# Check if Nginx Proxy Manager is already installed
if [ -d "/nginx-proxy-manager" ]; then
    echo "Nginx Proxy Manager is already installed."
else
    echo "Nginx Proxy Manager not found, installing..."
    mkdir ~/nginx-proxy-manager && cd ~/nginx-proxy-manager

    # Create the Docker Compose file
    filename="docker-compose.yml"
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

    echo "Docker Compose file created."

    # Start the Nginx Proxy Manager
    docker-compose up -d
    echo "Nginx Proxy Manager is now running."
fi
# Configure UFW
echo "Configuring UFW..."
ufw enable
ufw allow 80/tcp
ufw allow 443/tcp
ufw allow 81/tcp
ufw allow 22/tcp
ufw reload
ufw status
echo "Ports 80, 81, and 443 have been opened."