#!/bin/bash

# Update script for QGIS Cloud Browser

set -e

echo "Updating QGIS Cloud Browser..."

# Pull latest changes
git pull origin main

# Pull latest Docker images
docker compose pull

# Rebuild containers
docker compose build --no-cache

# Restart with new images
docker compose up -d

echo "Update complete!"
docker compose ps