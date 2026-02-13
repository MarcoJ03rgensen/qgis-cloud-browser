# Installation Guide

## Prerequisites

### System Requirements

**Minimum:**
- CPU: 1 core
- RAM: 2GB
- Disk: 10GB
- OS: Linux, macOS, Windows (with WSL2)

**Recommended:**
- CPU: 2+ cores
- RAM: 4GB+
- Disk: 20GB+ SSD
- OS: Ubuntu 22.04 LTS

**Optimal (Oracle Cloud Free Tier):**
- CPU: 4 ARM cores
- RAM: 24GB
- Disk: 200GB
- OS: Ubuntu 22.04 ARM64

### Software Requirements

- Docker Engine 20.10+
- Docker Compose 2.0+
- Git

## Installation Methods

### Method 1: Quick Install (Recommended)

**For Linux/macOS:**

```bash
# One-liner installation
curl -fsSL https://raw.githubusercontent.com/MarcoJ03rgensen/qgis-cloud-browser/main/install.sh | bash
```

**For manual installation:**

```bash
# Clone repository
git clone https://github.com/MarcoJ03rgensen/qgis-cloud-browser.git
cd qgis-cloud-browser

# Run deployment script
chmod +x deploy.sh
./deploy.sh
```

The script will:
1. Check dependencies
2. Create directories
3. Generate secure passwords
4. Build containers
5. Start services

### Method 2: Manual Installation

#### Step 1: Install Docker

**Ubuntu/Debian:**
```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER
```

**CentOS/RHEL:**
```bash
sudo yum install -y docker
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER
```

**macOS:**
```bash
brew install docker
# Or download Docker Desktop from docker.com
```

**Windows:**
- Install Docker Desktop: https://www.docker.com/products/docker-desktop
- Enable WSL2 integration

#### Step 2: Install Docker Compose

**Linux:**
```bash
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

**macOS/Windows:**
- Included with Docker Desktop

#### Step 3: Clone Repository

```bash
git clone https://github.com/MarcoJ03rgensen/qgis-cloud-browser.git
cd qgis-cloud-browser
```

#### Step 4: Configure Environment

```bash
# Copy example config
cp .env.example .env

# Edit configuration
nano .env  # or vim, code, etc.
```

**Important settings:**
```bash
VNC_PASSWORD=your-secure-password-here
VNC_RESOLUTION=1920x1080
CPU_LIMIT=2
MEMORY_LIMIT=4G
```

#### Step 5: Create Directories

```bash
mkdir -p data qgis-projects qgis-plugins nginx/certs
touch data/.gitkeep qgis-projects/.gitkeep qgis-plugins/.gitkeep
```

#### Step 6: Build and Start

```bash
# Build containers (first time - takes 5-10 minutes)
docker compose build

# Start services
docker compose up -d

# Check status
docker compose ps
```

#### Step 7: Access QGIS

Open browser:
- Control Panel: http://localhost:8080
- Direct QGIS: http://localhost:6080/vnc.html

## Cloud Deployment

### Oracle Cloud Free Tier

See [ORACLE_CLOUD.md](ORACLE_CLOUD.md) for detailed guide.

### AWS EC2

```bash
# Launch instance
# Instance type: t2.medium (2 vCPU, 4GB RAM)
# OS: Ubuntu 22.04
# Security group: Allow ports 22, 80, 443

# SSH into instance
ssh -i key.pem ubuntu@<instance-ip>

# Install Docker
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker ubuntu
exit

# SSH back in and deploy
ssh -i key.pem ubuntu@<instance-ip>
git clone https://github.com/MarcoJ03rgensen/qgis-cloud-browser.git
cd qgis-cloud-browser
cp .env.example .env
# Edit .env with secure password
docker compose -f docker-compose.prod.yml up -d
```

### Google Cloud Platform

```bash
# Create instance
gcloud compute instances create qgis-cloud \
  --machine-type=e2-medium \
  --image-family=ubuntu-2204-lts \
  --image-project=ubuntu-os-cloud \
  --boot-disk-size=20GB

# SSH and deploy
gcloud compute ssh qgis-cloud
# Follow same steps as AWS
```

### DigitalOcean

```bash
# Create droplet via web interface
# Size: Basic - 2GB RAM ($12/month)
# Image: Ubuntu 22.04

# SSH and deploy
ssh root@<droplet-ip>
apt update && apt upgrade -y
curl -fsSL https://get.docker.com | sh
git clone https://github.com/MarcoJ03rgensen/qgis-cloud-browser.git
cd qgis-cloud-browser
./deploy.sh
```

## Verification

### Check Services

```bash
# All services should be "Up"
docker compose ps

# Expected output:
NAME                IMAGE                   STATUS
qgis-desktop        qgis-cloud-browser...   Up
qgis-nginx          nginx:alpine            Up
qgis-novnc          theasp/novnc:latest     Up
```

### Check Logs

```bash
# View all logs
docker compose logs

# Follow logs in real-time
docker compose logs -f

# Check specific service
docker compose logs qgis-desktop
```

### Test Access

```bash
# Test from command line
curl http://localhost:8080

# Should return HTML of dashboard
```

### Test QGIS

1. Open browser: http://localhost:8080
2. Click "Launch QGIS"
3. Enter VNC password
4. QGIS Desktop should load

## Post-Installation

### Setup SSL (Production)

```bash
# For production with domain
./scripts/setup-ssl.sh yourdomain.com
```

### Enable Auto-Start

```bash
# Make containers start on boot
docker compose up -d
# Containers will auto-restart on system reboot
```

### Setup Backups

```bash
# Manual backup
./scripts/backup.sh

# Schedule automatic backups (cron)
crontab -e
# Add: 0 2 * * * cd /path/to/qgis-cloud-browser && ./scripts/backup.sh
```

## Updating

```bash
# Pull latest changes
git pull origin main

# Update containers
./scripts/update.sh
```

## Uninstall

```bash
# Stop and remove containers
docker compose down

# Remove volumes (careful - deletes data!)
docker volume rm qgis-cloud-browser_qgis-config

# Remove images
docker rmi $(docker images 'qgis-cloud-browser*' -q)

# Remove directory
cd ..
rm -rf qgis-cloud-browser
```

## Troubleshooting

See [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for common issues.

## Next Steps

- [Configure QGIS](CONFIGURATION.md)
- [Deploy to Cloud](DEPLOYMENT.md)
- [Install Plugins](../README.md#installing-plugins)
- [Upload Data](../README.md#uploading-data)