# 🌍 QGIS Cloud Browser

> **Run full QGIS Desktop in your browser** - Complete GIS workstation accessible from anywhere, with zero client-side installation.

[![Docker](https://img.shields.io/badge/docker-%230db7ed.svg?style=for-the-badge&logo=docker&logoColor=white)](https://www.docker.com/)
[![QGIS](https://img.shields.io/badge/QGIS-LTR-green?style=for-the-badge&logo=qgis)](https://qgis.org/)
[![noVNC](https://img.shields.io/badge/noVNC-HTML5-orange?style=for-the-badge)](https://novnc.com/)

## ✨ Features

- 🖥️ **Full QGIS Desktop** - Complete QGIS LTR with all features
- 🔌 **Plugin Support** - Install and use any QGIS plugin
- 🌐 **Browser-Based** - Access via any modern web browser
- 🚀 **Zero Client Storage** - Everything runs in the cloud
- 🎨 **Beautiful Control Panel** - Modern HTML5 dashboard
- 🔒 **Secure** - SSL/TLS encryption with password protection
- 💰 **Free Tier Ready** - Optimized for Oracle Cloud Free Tier
- 📱 **Responsive** - Works on desktop, tablet, and mobile

## 🏗️ Architecture

```
                User's Browser
                      |
                   [HTTPS]
                      |
                 Nginx Proxy
              (SSL + Auth)
                /     \
        Dashboard    noVNC
                      |
                  [WebSocket]
                      |
                   TigerVNC
                      |
                     Xvfb
                      |
                QGIS Desktop
                 + Plugins
```

## 🚀 Quick Start

### Prerequisites

- Docker 20.10+
- Docker Compose 2.0+
- 4GB+ RAM (8GB recommended)

### Deploy in 30 seconds

```bash
git clone https://github.com/MarcoJ03rgensen/qgis-cloud-browser.git
cd qgis-cloud-browser
./deploy.sh
```

Access at `http://localhost:8080`

## ☁️ Oracle Cloud Free Tier

**Perfect for QGIS Cloud:**
- 4 ARM CPU cores
- 24GB RAM
- 200GB storage
- **Always Free**

[Setup Guide](docs/ORACLE_CLOUD.md)

## 📖 Documentation

- [Installation Guide](docs/INSTALLATION.md)
- [Configuration](docs/CONFIGURATION.md)
- [Cloud Deployment](docs/DEPLOYMENT.md)
- [Troubleshooting](docs/TROUBLESHOOTING.md)

## 🔒 Security

- Password-protected VNC
- Optional SSL/TLS
- Firewall configuration
- Regular security updates

## 📊 Resource Usage

**Minimum:** 1 CPU, 2GB RAM, 10GB disk  
**Recommended:** 2+ CPU, 4GB RAM, 20GB disk  
**Oracle Free Tier:** 4 CPU, 24GB RAM, 200GB disk

## 🤝 Contributing

Contributions welcome! See [CONTRIBUTING.md](CONTRIBUTING.md)

## 📄 License

MIT License - see [LICENSE](LICENSE)

## 🙏 Credits

- QGIS Project
- noVNC
- TigerVNC
- Kartoza docker-qgis

---

**Made with ❤️ for the GIS community**