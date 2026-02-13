#!/bin/bash

# SSL Setup Script for QGIS Cloud Browser
# Usage: ./scripts/setup-ssl.sh yourdomain.com

set -e

DOMAIN=$1

if [ -z "$DOMAIN" ]; then
    echo "Usage: $0 <domain>"
    echo "Example: $0 qgis.example.com"
    exit 1
fi

echo "Setting up SSL for $DOMAIN..."

# Create certs directory
mkdir -p nginx/certs

# Check if certbot is installed
if ! command -v certbot &> /dev/null; then
    echo "Installing certbot..."
    sudo apt-get update
    sudo apt-get install -y certbot
fi

# Stop nginx if running
docker compose stop nginx || true

# Get SSL certificate
sudo certbot certonly --standalone -d $DOMAIN \
    --non-interactive \
    --agree-tos \
    --email admin@$DOMAIN

# Copy certificates
sudo cp /etc/letsencrypt/live/$DOMAIN/fullchain.pem nginx/certs/cert.pem
sudo cp /etc/letsencrypt/live/$DOMAIN/privkey.pem nginx/certs/key.pem

# Update .env
sed -i 's/ENABLE_SSL=false/ENABLE_SSL=true/' .env

echo "SSL certificates installed!"
echo "Remember to:"
echo "1. Update nginx/default.conf to enable SSL server block"
echo "2. Restart containers: docker compose restart nginx"
echo "3. Set up auto-renewal: sudo certbot renew --dry-run"