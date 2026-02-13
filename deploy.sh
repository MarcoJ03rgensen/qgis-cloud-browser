#!/bin/bash
set -e

echo "================================================"
echo "   QGIS Cloud Browser - Quick Deployment"
echo "================================================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo -e "${RED}Error: Docker is not installed${NC}"
    echo "Please install Docker from: https://docs.docker.com/get-docker/"
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker compose &> /dev/null; then
    echo -e "${RED}Error: Docker Compose is not installed${NC}"
    echo "Please install Docker Compose from: https://docs.docker.com/compose/install/"
    exit 1
fi

echo -e "${GREEN}✓ Docker found${NC}"
echo -e "${GREEN}✓ Docker Compose found${NC}"
echo ""

# Create necessary directories
echo "Creating directories..."
mkdir -p data qgis-projects qgis-plugins nginx/certs
touch data/.gitkeep qgis-projects/.gitkeep qgis-plugins/.gitkeep
echo -e "${GREEN}✓ Directories created${NC}"
echo ""

# Create .env file if it doesn't exist
if [ ! -f .env ]; then
    echo "Creating .env file from template..."
    cp .env.example .env
    
    # Generate random password
    RANDOM_PASSWORD=$(openssl rand -base64 12 2>/dev/null || echo "qgis$(date +%s)")
    
    # Update password in .env
    sed -i.bak "s/VNC_PASSWORD=.*/VNC_PASSWORD=$RANDOM_PASSWORD/" .env && rm .env.bak 2>/dev/null || true
    
    echo -e "${GREEN}✓ .env file created${NC}"
    echo -e "${YELLOW}Your VNC password: $RANDOM_PASSWORD${NC}"
    echo -e "${YELLOW}(Save this password - you'll need it to access QGIS)${NC}"
else
    echo -e "${YELLOW}.env file already exists, skipping...${NC}"
fi
echo ""

# Build and start containers
echo "Building and starting containers..."
echo "This may take 5-10 minutes on first run..."
echo ""

docker compose build --no-cache
docker compose up -d

echo ""
echo -e "${GREEN}================================================${NC}"
echo -e "${GREEN}   QGIS Cloud Browser is now running!${NC}"
echo -e "${GREEN}================================================${NC}"
echo ""
echo "Access points:"
echo -e "  • Control Panel: ${GREEN}http://localhost:8080${NC}"
echo -e "  • Direct QGIS:   ${GREEN}http://localhost:6080/vnc.html${NC}"
echo ""
echo "To view logs:"
echo "  docker compose logs -f"
echo ""
echo "To stop:"
echo "  docker compose down"
echo ""
echo -e "${YELLOW}Note: First startup may take 30-60 seconds${NC}"
echo ""