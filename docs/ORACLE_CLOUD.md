# Oracle Cloud Free Tier Deployment Guide

## Why Oracle Cloud Free Tier?

Oracle Cloud offers the most generous free tier for running QGIS Cloud Browser:

- **4 ARM CPU cores** (Ampere A1)
- **24GB RAM**
- **200GB storage**
- **10TB monthly egress**
- **Always Free** (no credit card charges after trial)

This is perfect for running QGIS with multiple concurrent sessions.

## Step-by-Step Deployment

### 1. Create Oracle Cloud Account

1. Go to https://www.oracle.com/cloud/free/
2. Click "Start for free"
3. Fill in your details
4. Verify your email and phone
5. Add payment method (for identity verification only)

### 2. Create Compute Instance

1. **Login to Oracle Cloud Console**
   - https://cloud.oracle.com/

2. **Navigate to Compute Instances**
   - Menu → Compute → Instances

3. **Create Instance**
   - Click "Create Instance"
   - Name: `qgis-cloud-browser`

4. **Configure Shape**
   - Click "Change Shape"
   - Select "Ampere" (ARM)
   - Shape: `VM.Standard.A1.Flex`
   - OCPUs: **4**
   - Memory: **24GB**

5. **Configure Networking**
   - VCN: Create new or use existing
   - Subnet: Public subnet
   - Assign public IPv4: **YES**

6. **Add SSH Key**
   - Generate new key pair OR
   - Paste your public key
   - **Download private key** (you'll need this!)

7. **Configure Boot Volume**
   - Image: **Ubuntu 22.04**
   - Boot volume size: **50GB** (or more)

8. **Create**
   - Click "Create"
   - Wait 2-3 minutes for provisioning

### 3. Configure Firewall Rules

1. **Navigate to VCN**
   - Menu → Networking → Virtual Cloud Networks
   - Click your VCN

2. **Security Lists**
   - Click "Security Lists"
   - Click "Default Security List"

3. **Add Ingress Rules**
   
   **Rule 1: HTTP**
   - Source CIDR: `0.0.0.0/0`
   - IP Protocol: TCP
   - Destination Port: `80`
   
   **Rule 2: HTTPS**
   - Source CIDR: `0.0.0.0/0`
   - IP Protocol: TCP
   - Destination Port: `443`
   
   **Rule 3: SSH**
   - Source CIDR: `0.0.0.0/0`
   - IP Protocol: TCP
   - Destination Port: `22`

### 4. Configure OS Firewall

SSH into your instance:

```bash
ssh -i ~/.ssh/oracle_cloud_key ubuntu@<your-public-ip>
```

Configure firewall:

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Configure firewall
sudo iptables -I INPUT 6 -m state --state NEW -p tcp --dport 80 -j ACCEPT
sudo iptables -I INPUT 6 -m state --state NEW -p tcp --dport 443 -j ACCEPT
sudo netfilter-persistent save

# Or use ufw (simpler)
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 22/tcp
sudo ufw enable
```

### 5. Install Docker

```bash
# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Add user to docker group
sudo usermod -aG docker $USER

# Logout and login again for group changes
exit
# SSH back in
```

### 6. Deploy QGIS Cloud Browser

```bash
# Clone repository
git clone https://github.com/MarcoJ03rgensen/qgis-cloud-browser.git
cd qgis-cloud-browser

# Configure environment
cp .env.example .env
nano .env  # Edit settings

# Generate secure password
VNC_PASS=$(openssl rand -base64 16)
echo "Your VNC password: $VNC_PASS"
echo "(Save this!)"

# Update .env with password
sed -i "s/VNC_PASSWORD=.*/VNC_PASSWORD=$VNC_PASS/" .env

# Deploy using production config
docker compose -f docker-compose.prod.yml up -d

# Check status
docker compose ps
```

### 7. Access Your QGIS

Open your browser:
```
http://<your-oracle-instance-public-ip>
```

### 8. (Optional) Setup SSL with Let's Encrypt

```bash
# Install certbot
sudo apt install -y certbot

# Stop nginx temporarily
docker compose stop nginx

# Get certificate (replace with your domain)
sudo certbot certonly --standalone -d yourdomain.com

# Copy certificates
sudo cp /etc/letsencrypt/live/yourdomain.com/fullchain.pem nginx/certs/cert.pem
sudo cp /etc/letsencrypt/live/yourdomain.com/privkey.pem nginx/certs/key.pem
sudo chmod 644 nginx/certs/*.pem

# Update nginx config to enable SSL
# Uncomment SSL server block in nginx/default.conf

# Restart
docker compose up -d
```

### 9. Setup Auto-Renewal for SSL

```bash
# Create renewal hook
sudo nano /etc/letsencrypt/renewal-hooks/deploy/qgis-renew.sh
```

Add:
```bash
#!/bin/bash
cp /etc/letsencrypt/live/yourdomain.com/fullchain.pem /home/ubuntu/qgis-cloud-browser/nginx/certs/cert.pem
cp /etc/letsencrypt/live/yourdomain.com/privkey.pem /home/ubuntu/qgis-cloud-browser/nginx/certs/key.pem
chmod 644 /home/ubuntu/qgis-cloud-browser/nginx/certs/*.pem
cd /home/ubuntu/qgis-cloud-browser && docker compose restart nginx
```

Make executable:
```bash
sudo chmod +x /etc/letsencrypt/renewal-hooks/deploy/qgis-renew.sh
```

## Resource Monitoring

```bash
# Check resource usage
docker stats

# Check logs
docker compose logs -f

# System resources
htop
```

## Optimization Tips

1. **Reduce VNC Resolution** (if needed)
   ```bash
   # Edit .env
   VNC_RESOLUTION=1280x720
   VNC_COLOR_DEPTH=16
   ```

2. **Adjust Memory Limits**
   ```bash
   # Edit .env
   MEMORY_LIMIT=20G  # Use most of 24GB
   CPU_LIMIT=4       # Use all 4 cores
   ```

3. **Enable Swap** (optional)
   ```bash
   sudo fallocate -l 4G /swapfile
   sudo chmod 600 /swapfile
   sudo mkswap /swapfile
   sudo swapon /swapfile
   echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
   ```

## Troubleshooting

**Can't connect?**
- Check Oracle Cloud security lists
- Check OS firewall: `sudo iptables -L`
- Check containers: `docker compose ps`

**Out of memory?**
- Reduce VNC resolution
- Add swap space
- Check with `docker stats`

**Slow performance?**
- Lower color depth to 16
- Reduce resolution
- Check network latency

## Cost Monitoring

Always Free resources:
- 4 ARM cores: **FREE**
- 24GB RAM: **FREE**
- 200GB storage: **FREE**
- 10TB egress: **FREE**

As long as you stay within these limits, there are **NO CHARGES**.

## Backup

```bash
# Regular backup
./scripts/backup.sh

# Copy backup to local machine
scp ubuntu@<ip>:~/qgis-cloud-browser/backups/*.tar.gz .
```

---

**Your QGIS Cloud Browser is now running on Oracle Cloud Free Tier!**