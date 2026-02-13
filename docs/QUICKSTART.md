# Quick Start Guide

## 5-Minute Setup

### 1. Prerequisites Check

```bash
# Check Docker
docker --version
# Should show: Docker version 20.10.x or higher

# Check Docker Compose
docker compose version
# Should show: Docker Compose version v2.x.x or higher
```

Don't have Docker? Install:
```bash
curl -fsSL https://get.docker.com | sh
```

### 2. Download

```bash
git clone https://github.com/MarcoJ03rgensen/qgis-cloud-browser.git
cd qgis-cloud-browser
```

### 3. Deploy

```bash
./deploy.sh
```

Wait 5-10 minutes for first-time build.

### 4. Access

Open browser: **http://localhost:8080**

Click "Launch QGIS" and enter the VNC password shown during deployment.

## Done! 🎉

You now have full QGIS Desktop running in your browser.

---

## What Next?

### Upload GIS Data

```bash
# Copy files to data directory
cp /path/to/your/data.shp ./data/
```

In QGIS: Layer → Add Layer → Add Vector Layer → Browse to `/data/data.shp`

### Install Plugins

In QGIS:
1. Plugins → Manage and Install Plugins
2. Search for plugin
3. Click Install

### Save Your Work

Projects save to `./qgis-projects/` automatically.

### Stop/Start

```bash
# Stop
docker compose down

# Start again
docker compose up -d
```

---

## Cloud Deployment (Oracle Free Tier)

### Quick Oracle Cloud Setup

1. **Create account**: https://cloud.oracle.com/
2. **Launch instance**: 4 ARM cores, 24GB RAM, Ubuntu 22.04
3. **SSH in and run:**

```bash
curl -fsSL https://get.docker.com | sh
git clone https://github.com/MarcoJ03rgensen/qgis-cloud-browser.git
cd qgis-cloud-browser
cp .env.example .env
# Set strong password in .env
docker compose -f docker-compose.prod.yml up -d
```

4. **Configure firewall**: Allow ports 80, 443
5. **Access**: http://your-instance-ip

Detailed guide: [docs/ORACLE_CLOUD.md](ORACLE_CLOUD.md)

---

## Tips

✅ **Performance Tip**: Lower resolution if slow
```bash
# Edit .env
VNC_RESOLUTION=1280x720
```

✅ **Security Tip**: Change default password
```bash
# Edit .env
VNC_PASSWORD=your-strong-password-here
```

✅ **Backup Tip**: Regular backups
```bash
./scripts/backup.sh
```

---

## Get Help

- **Docs**: [README.md](../README.md)
- **Issues**: https://github.com/MarcoJ03rgensen/qgis-cloud-browser/issues
- **Email**: marcobirkedahl@gmail.com

---

**Happy Mapping! 🗺️**